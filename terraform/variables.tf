# AWS Setup
variable "region" { default = "us-west-2" }
variable "aws_profile" { default = "default" }

# Required variables
variable "ephemeral_app_name" {}

# VPC Setup
variable "vpc_cidr_block" {}
variable "subnet_init_value" {}
variable "subnet_count" {}
variable "ingress_port" {}
variable "ingress_allowed" {}
variable "sg_groups" { default = null }

# Fargate ECS IAM Configurations(required)
variable "dockerhub_credentials_secrets_arn" {}
variable "fargate_ecs_task_execution_role_arn" {}

# Cantaloupe S3 Src Bucket Configuration
variable "force_destroy_src_bucket" { default = "false" }

# Cantaloupe Application Settings
variable "memory" { default = "2048" }
variable "cpu" { default = "1024" }
variable "registry_auth_arn" {}
variable "image_url" {}
variable "listening_port" {}
variable "forwarding_port" {}
variable "disable_load_balancer" { default = 0 }
variable "enable_load_balancer" { default = 0 }
variable "container_count" { default = 1 }
variable "assign_public_ip" { default = true }
variable "target_group_arn" { default = null }

# Cantaloupe Environment Variables
variable "cantaloupe_enable_admin" { default = "true" }
variable "cantaloupe_admin_secret" { default = "secretpassword" }
variable "cantaloupe_enable_cache_server" { default = "false" }
variable "cantaloupe_cache_server_derivative" { default = "S3Cache" }
variable "cantaloupe_cache_server_derivative_ttl" { default = "0" }
variable "cantaloupe_cache_server_purge_missing" { default = "true" }
variable "cantaloupe_processor_selection_strategy" { default = "ManualSelectionStrategy" }
variable "cantaloupe_manual_processor_jp2" { default = "KakaduNativeProcessor" }
variable "cantaloupe_s3_cache_access_key" { default = "something" }
variable "cantaloupe_s3_cache_secret_key" { default = "something" }
variable "cantaloupe_s3_cache_endpoint" { default = "us-west-2" }
variable "cantaloupe_s3_cache_bucket" { default = "something" }
variable "cantaloupe_s3_source_access_key" { default = "something" }
variable "cantaloupe_s3_source_secret_key" { default = "something" }
variable "cantaloupe_s3_source_endpoint" { default = "us-west-2" }
variable "cantaloupe_s3_source_basiclookup_suffix" { default = ".jpx" }
variable "cantaloupe_source_static" { default = "S3Source" }
variable "cantaloupe_heapsize" { default = "2g" }

locals {
  fargate_ecs_role_name    = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-ecs-role"
  fargate_cluster_name     = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-cluster"
  fargate_service_name     = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-service"
  fargate_definition_name  = "${var.ephemeral_app_name}-cantaloupe-ephemeral-fargate-definition"
  cantaloupe_s3_src_bucket = "${var.ephemeral_app_name}-cantaloupe-ephemeral-src-bucket"
  sg_name                  = "${var.ephemeral_app_name}-cantaloupe-ephemeral-security-group"
}

