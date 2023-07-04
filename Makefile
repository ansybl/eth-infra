IMAGE_TAG=latest
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
WORKSPACE?=mainnet
GETH_IMAGE_NAME=eth-node-geth-$(WORKSPACE)
GETH_DOCKER_IMAGE=$(REGISTRY)/$(GETH_IMAGE_NAME)


docker/build/geth:
	docker pull ethereum/client-go
	docker tag ethereum/client-go $(GETH_DOCKER_IMAGE)

docker/build: docker/build/geth

docker/login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io

docker/push/geth:
	docker push $(GETH_DOCKER_IMAGE):$(IMAGE_TAG)

docker/push: docker/push/geth

docker/compose:
	docker-compose up

docker/run/geth:
	docker run \
	--publish 8551:8551 \
	--publish 8545:8545 \
	--publish 8546:8546 \
	--publish 30303:30303 \
	--rm $(GETH_DOCKER_IMAGE)

docker/run/geth/sh:
	docker run -it --entrypoint /bin/sh --rm $(GETH_DOCKER_IMAGE)

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

devops/terraform/destroy/all: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy

devops/terraform/output: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output
