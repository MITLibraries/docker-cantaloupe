.PHONY: help dist publish promote
SHELL=/bin/bash
ECR_REGISTRY=672626379771.dkr.ecr.us-east-1.amazonaws.com
DATETIME:=$(shell date -u +%Y%m%dT%H%M%SZ)

help: ## Print this message
	@awk 'BEGIN { FS = ":.*##"; print "Usage:  make <target>\n\nTargets:" } \
		/^[-_[:alpha:]]+:.?*##/ { printf "  %-15s%s\n", $$1, $$2 }' $(MAKEFILE_LIST)

dist: ## Build docker image
	docker build -t $(ECR_REGISTRY)/cantaloupe-stage:latest \
		-t $(ECR_REGISTRY)/cantaloupe-stage:`git describe --always` \
		-t cantaloupe:latest .

publish: dist ## Build, tag and push
	$$(aws ecr get-login --no-include-email --region us-east-1)
	docker push $(ECR_REGISTRY)/cantaloupe-stage:latest
	docker push $(ECR_REGISTRY)/cantaloupe-stage:`git describe --always`
	aws ecs update-service --cluster cantaloupe-stage-cluster --service cantaloupe-stage --region us-east-1 --force-new-deployment

promote: ## Promote the current staging build to production
	$$(aws ecr get-login --no-include-email --region us-east-1)
	docker pull $(ECR_REGISTRY)/cantaloupe-stage:latest
	docker tag $(ECR_REGISTRY)/cantaloupe-stage:latest $(ECR_REGISTRY)/cantaloupe-prod:latest
	docker tag $(ECR_REGISTRY)/cantaloupe-stage:latest $(ECR_REGISTRY)/cantaloupe-prod:$(DATETIME)
	docker push $(ECR_REGISTRY)/cantaloupe-prod:latest
	docker push $(ECR_REGISTRY)/cantaloupe-prod:$(DATETIME)
	aws ecs update-service --cluster cantaloupe-prod-cluster --service cantaloupe-prod --region us-east-1 --force-new-deployment
