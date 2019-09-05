# aws_terraform_module_fargate [![Build Status](https://travis-ci.com/UCLALibrary/aws_terraform_module_fargate.svg?branch=master)](https://travis-ci.com/UCLALibrary/aws_terraform_module_fargate)

## Prerequisites for using docker-cantaloupe terraform
* Supply a prefix to name your AWS resources with. Usually an alias similar to your username will suffice
  * `ephemeral_app_name = "joebruin"`
* This setup assumes you have no VPC set up. We want the ephemeral environments isolated from existing resources
  * The default setup will create a `10.0.0.0/16` VPC network and a `10.0.1.0/24` subnet allocated to the created region. If you're not sure what to do here, its suggested you leave this alone unless you have conflicting IP spaces in your AWS environment
  * If you want to override and of the existing VPC configurations, you'll need to supply this information. Note that you'll need to 
    * The following example will create a `10.1.0.0/16` VPC network and 2 subnets in different AZ zones in the same region `10.1.1.0/24` and `10.1.2.0/24`:
    * `vpc_cidr_block    = 10.1.0.0/16`
    * `subnet_init_value = 1`
    * `subnet_count      = 2`
* Security Group Configuration
  * Supply the port in which your application runs on. There is no port forwarding allowed in Fargate setups
    * `ingress_port = [8181, 8182]`
  * Supply what networks and/or IPs you want to allow access to your Fargate container
    * `ingress_allowed = [0.0.0.0/16]`
  * If you have more restrictive needs and only want to allow AWS resources to access your containers, you can define the IDs of the resources in the following:
    * `sg_groups = ["${aws_lb.main.id}"]


## Dependencies
* ephemeral app name as a vriable
* Security group ID for ECS service to attach
* VPC Subnets used
* Container definitions
* Memory/CPU specifications
* Registry URL
* Registry credentials for authentication
