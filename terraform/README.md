# aws_terraform_module_fargate [![Build Status](https://travis-ci.com/UCLALibrary/aws_terraform_module_fargate.svg?branch=master)](https://travis-ci.com/UCLALibrary/aws_terraform_module_fargate)

## Prerequisites for using docker-cantaloupe terraform
* Supply a prefix to name your AWS resources with. Usually an alias similar to your username will suffice
  * ephemeral_app_name = "joebruin"
* This setup assumes you have no VPC set up. We want the ephemeral environments isolated from existing resources
  * The default setup will create a 10.0.0.0/16 VPC network and a 10.0.1.0/24 subnet allocated to the created region. If you want to override and of the existing VPC configurations, you'll need to supply this information. Note that you'll need to 
    * `vpc_cidr_block    = 10.1.0.0/16`
    * `subnet_init_value = 1`
    * `subnet_count      = 1`

## Dependencies
* ephemeral app name as a vriable
* Security group ID for ECS service to attach
* VPC Subnets used
* Container definitions
* Memory/CPU specifications
* Registry URL
* Registry credentials for authentication
