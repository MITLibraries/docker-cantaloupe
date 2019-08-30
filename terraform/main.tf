terraform {
  backend "remote" {}
}

provider "aws" {
  region  = "${var.region}"
}

data "template_file" "ecs_iam_init" {
  template      = "${file("policies/secrets-manager-dockerhub-auth.json.tpl")}"
  vars          = {
    secrets_arn = "${var.dockerhub_credentials_secrets_arn}"
  }
}

module "cantaloupe_fargate_ecs_iam_role" {
#  source                 = "git::https://github.com/UCLALibrary/aws_terraform_module_iam_role.git"
  source                     = "git::https://github.com/UCLALibrary/aws_terraform_module_iam_role.git?ref=IIIF-395"
  iam_role_name              = "${local.fargate_ecs_role_name}"
  iam_assume_policy_document = "${file("policies/assume-role-policy.json")}"
}

resource "aws_iam_policy" "fargate_ecs_access_dockerhub_registry_policy" {
  name   = "${local.fargate_ecs_role_name}-dockerhub-credentials-access"
  policy = "${data.template_file.ecs_iam_init.rendered}"
}

resource "aws_iam_policy_attachment" "fargate_ecs_execution_role_policy_attachment" {
  name       = "${local.fargate_ecs_role_name}"
  roles      = ["${module.cantaloupe_fargate_ecs_iam_role.iam_role_name}"]
  policy_arn = "${var.fargate_ecs_task_execution_role_arn}"
}

