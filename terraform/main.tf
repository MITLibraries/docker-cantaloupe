terraform {
  backend "remote" {}
}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.region}"
}

data "template_file" "ecs_iam_init" {
  template      = "${file("policies/secrets-manager-dockerhub-auth.json.tpl")}"
  vars          = {
    secrets_arn = "${var.dockerhub_credentials_secrets_arn}"
  }
}


module "cantaloupe_vpc" {
  source                    = "git::https://github.com/UCLALibrary/aws_terraform_module_vpc.git"
  vpc_cidr_block            = "${var.vpc_cidr_block}"
  subnet_init_value         = "${var.subnet_init_value}"
  subnet_count              = "${var.subnet_count}"
}

module "cantaloupe_fargate_sg" {
  source           = "git::https://github.com/UCLALibrary/aws_terraform_module_security_group.git"
  sg_name          = "${local.sg_name}"
  sg_description   = "${local.sg_name}"
  vpc_id           = "${module.cantaloupe_vpc.vpc_main_id}"
  ingress_ports    = "${var.ingress_port}"
  ingress_allowed  = "${var.ingress_allowed}"
  sg_groups        = "${var.sg_groups}"
}

module "cantaloupe_fargate_ecs_iam_role" {
  source                     = "git::https://github.com/UCLALibrary/aws_terraform_module_iam_role.git"
  iam_role_name              = "${local.fargate_ecs_role_name}"
  iam_assume_policy_document = "${file("policies/assume-role-policy.json")}"
}

resource "aws_iam_policy" "fargate_ecs_access_dockerhub_registry_policy" {
  name   = "${local.fargate_ecs_role_name}-dockerhub-credentials-access"
  policy = "${data.template_file.ecs_iam_init.rendered}"
}

resource "aws_iam_policy_attachment" "fargate_ecs_execution_role_policy_attachment" {
  name       = "${local.fargate_ecs_role_name}-attach-ecs-execution-privs"
  roles      = ["${module.cantaloupe_fargate_ecs_iam_role.iam_role_name}"]
  policy_arn = "${var.fargate_ecs_task_execution_role_arn}"
}

resource "aws_iam_policy_attachment" "fargate_credentials_secrets_privilege" {
  name       = "${local.fargate_ecs_role_name}-attach-secrets-privs"
  roles      = ["${module.cantaloupe_fargate_ecs_iam_role.iam_role_name}"]
  policy_arn = "${aws_iam_policy.fargate_ecs_access_dockerhub_registry_policy.arn}"
}

module "cantaloupe_src_bucket" {
  source             = "git::https://github.com/UCLALibrary/aws_terraform_s3_module.git"
  bucket_name        = "${local.cantaloupe_s3_src_bucket}"
  bucket_region      = "${var.region}"
  force_destroy_flag = "${var.force_destroy_src_bucket}"
}


data "template_file" "fargate_cantaloupe_definition" {
  template = "${file("templates/env_vars.properties.tpl")}"
  vars          = {
    fargate_definition_name                 = "${local.fargate_definition_name}"
    registry_auth_arn                       = "${var.dockerhub_credentials_secrets_arn}"
    memory                                  = "${var.memory}"
    cpu                                     = "${var.cpu}"
    image_url                               = "${var.image_url}"
    listening_port                          = "${var.listening_port}"
    forwarding_port                         = "${var.listening_port}"
    cantaloupe_enable_admin                 = "${var.cantaloupe_enable_admin}"
    cantaloupe_admin_secret                 = "${var.cantaloupe_admin_secret}"
    cantaloupe_enable_cache_server          = "${var.cantaloupe_enable_cache_server}"
    cantaloupe_cache_server_derivative      = "${var.cantaloupe_cache_server_derivative}"
    cantaloupe_cache_server_derivative_ttl  = "${var.cantaloupe_cache_server_derivative_ttl}"
    cantaloupe_cache_server_purge_missing   = "${var.cantaloupe_cache_server_purge_missing}"
    cantaloupe_processor_selection_strategy = "${var.cantaloupe_processor_selection_strategy}"
    cantaloupe_manual_processor_jp2         = "${var.cantaloupe_manual_processor_jp2}"
    cantaloupe_s3_cache_access_key          = "${var.cantaloupe_s3_cache_access_key}"
    cantaloupe_s3_cache_secret_key          = "${var.cantaloupe_s3_cache_secret_key}"
    cantaloupe_s3_cache_endpoint            = "${var.cantaloupe_s3_cache_endpoint}"
    cantaloupe_s3_cache_bucket              = "${var.cantaloupe_s3_cache_bucket}"
    cantaloupe_s3_source_access_key         = "${var.cantaloupe_s3_source_access_key}"
    cantaloupe_s3_source_secret_key         = "${var.cantaloupe_s3_source_secret_key}"
    cantaloupe_s3_source_endpoint           = "${var.cantaloupe_s3_source_endpoint}"
    cantaloupe_s3_source_bucket             = "${local.cantaloupe_s3_src_bucket}"
    cantaloupe_s3_source_basiclookup_suffix = "${var.cantaloupe_s3_source_basiclookup_suffix}"
    cantaloupe_source_static                = "${var.cantaloupe_source_static}"
    cantaloupe_heapsize                     = "${var.cantaloupe_heapsize}"
  }
}

module "cantaloupe_fargate" {
  source                  = "git::https://github.com/UCLALibrary/aws_terraform_module_fargate.git"
  memory                  = "${var.memory}"
  cpu                     = "${var.cpu}"
  execution_role_arn      = "${module.cantaloupe_fargate_ecs_iam_role.iam_role_arn}"
  registry_auth_arn       = "${var.registry_auth_arn}"
  image_url               = "${var.image_url}"
  listening_port          = "${var.listening_port}"
  forwarding_port         = "${var.listening_port}"
  disable_load_balancer   = "${var.disable_load_balancer}"
  fargate_cluster_name    = "${local.fargate_cluster_name}"
  fargate_service_name    = "${local.fargate_service_name}"
  fargate_definition_name = "${local.fargate_definition_name}"
  sg_id                   = "${module.cantaloupe_fargate_sg.id}"
  vpc_subnet_ids          = "${module.cantaloupe_vpc.vpc_subnet_ids}"
  container_definitions   = "${data.template_file.fargate_cantaloupe_definition.rendered}"
}

