IMAGE_TAG=latest
PROJECT=dfpl-playground
WORKSPACE?=mainnet


format: devops/terraform/format

lint: devops/terraform/lint

devops/terraform/select/%:
	terraform -chdir=terraform workspace select $* || terraform -chdir=terraform workspace new $*

devops/terraform/format:
	terraform -chdir=terraform fmt -recursive -diff

devops/terraform/lint:
	terraform -chdir=terraform fmt -recursive -diff -check

devops/terraform/init:
	terraform -chdir=terraform init -reconfigure

devops/terraform/plan: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform plan

devops/terraform/apply: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply -auto-approve

# only redeploy the VM
devops/terraform/redeploy/vm/%: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply -replace=module.gce_$*_worker_container.google_compute_instance.this -target=module.gce_$*_worker_container.google_compute_instance.this

devops/terraform/redeploy/prysm: devops/terraform/redeploy/vm/prysm

devops/terraform/redeploy/geth: devops/terraform/redeploy/vm/geth

devops/terraform/redeploy: devops/terraform/redeploy/prysm devops/terraform/redeploy/geth
	make devops/terraform/apply

devops/terraform/reset/vm/%:
	gcloud --project $(PROJECT) compute instances reset $*

devops/terraform/reset/prysm: devops/terraform/reset/vm/eth-node-prysm-cdb502a9-$(WORKSPACE)

# make sure to gracefully stop the geth container to avoid chain data corruption
devops/terraform/reset/geth: devops/terraform/reset/vm/eth-node-geth-c84e80e6-$(WORKSPACE)

devops/terraform/reset: devops/terraform/reset/prysm devops/terraform/reset/geth

devops/terraform/destroy/all: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy

devops/terraform/output: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output
