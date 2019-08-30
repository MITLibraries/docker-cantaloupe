# AWS Setup
variable "region" { default = "us-west-2" }

# Required variables
variable "ephemeral_name_prefix" {}
variable "dockerhub_credentials_secrets_arn" {}
variable "fargate_ecs_task_execution_role_arn" {}

locals {
  fargate_ecs_role_name = "${var.ephemeral_name_prefix}-cantaloupe-ephemeral"
}

