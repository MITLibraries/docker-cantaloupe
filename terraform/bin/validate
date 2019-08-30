#!/bin/bash

# https://github.com/hashicorp/terraform/issues/21408
# This is needed because the provider schema region is needed, but for testing purposes,
# we don't want to set this on each module.
export AWS_DEFAULT_REGION="us-west-2"

terraform init -backend=false
terraform validate
