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

devops/terraform/select/%:
	terraform -chdir=terraform workspace select $* || terraform -chdir=terraform workspace new $*

devops/terraform/fmt:
	terraform -chdir=terraform fmt

devops/terraform/init:
	terraform -chdir=terraform init -reconfigure

devops/terraform/plan: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform plan

devops/terraform/apply: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply -auto-approve

# only destroy the VM
devops/terraform/destroy/%: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy -target=module.gce_$*_worker_container.google_compute_instance.this -auto-approve

devops/terraform/destroy: devops/terraform/destroy/geth devops/terraform/destroy/prysm

devops/terraform/redeploy/prysm: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/prysm
	make devops/terraform/apply

devops/terraform/redeploy/geth: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy/geth
	make devops/terraform/apply

devops/terraform/redeploy: devops/terraform/select/$(WORKSPACE) devops/terraform/destroy
	make devops/terraform/apply

devops/terraform/destroy/all: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy

devops/terraform/output: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output
