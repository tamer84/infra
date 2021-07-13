# Please, avoid running this from your machine!!! This project should always run using the pipeline.

![](https://codebuild.eu-central-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiNUtKT1JZRWtucFBLWVlVQ053L09ON0tIVmZQQ0FKUXRQcjFxU2hSUjZiVThkZXVmQ2tWWEVmRTdQUXNpVGtJOExrR1p4L0ZaWVNpdzZIMGZJcHY4SlRVPSIsIml2UGFyYW1ldGVyU3BlYyI6ImpEUFA3TGhGbHNNaVdxY0MiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)

## What is here?
This repository holds the AWS Infrastructure as Code for VPP.

The infrastructure is described using [Terraform](https://www.terraform.io/), the structure is described above:

* [account_resources](account_resources/): contains the resources related to the account itself, like DNS and Certificates, which are used for all the environments created in the same account
* [environment_resources](environment_resources/): contains the resources for the specific environment (dev, test, ...), the environments are individually managed using [Terraform Workspaces](https://www.terraform.io/docs/commands/workspace/index.html)

## How to start?

*Notice: the infrastructure is meant to be managed by the CICD pipeline only! Use this to manage non-standard infrastructure (dev, test, int and prod) and also to create ephemeral infra as you wish.*

1. Install [Terraform](https://www.terraform.io/downloads.html)
2. Install [AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3. Authenticate on AWS Cli using your access key id/secret using the [configure command](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)
4. Init terraform using [terraform init](https://www.terraform.io/docs/commands/init.html)
  - If you are setting up a new account, execute the command inside the [account_resources](account_resources) folder
  - If you are setting up a new environment or managing an existing environment execute the command inside the [environment_resources](environment_resources) folder
5. Select the environment (**Just do this for environment resources**)
  - If you are using an existing workspace: `terraform workspace select {env}`
  - If you are creating a new environment: `terraform workspace new {env}`
6. Now you can execute [terraform plan](https://www.terraform.io/docs/commands/plan.html) to check what is the current status of your resources
7. If that is the case, execute [terraform apply](https://www.terraform.io/docs/commands/apply.html) (carefully, be sure the changes you see in the plan are the ones you really intend to apply)

## Resources


### Axonserver 

Axonserver resource is described in [environment_resources/axon.tf](environment_resources/axon.tf).

To access the server (the files below mentioned will only be available after you run `terraform apply`): 
* Axon uses TLS on both Dashboard and GRPC ends, to access any of those endpoints you need to have the certificate which is output at [environment_resources/output/axonserver_cert.pem](environment_resources/output/axonserver_cert.pem)
* Also the server can be accessed via SSH, the key is also exposed in the output folder ([environment_resources/output/axonserver_key.pem](modules/ec2/output/dev/axonserver_key.pem)) (`ssh -i modules/ec2/output/dev/axonserver_key.pem ubuntu@axon.dev.vpp.mercedes-benz.io`)
