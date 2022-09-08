# Terraform - AWS Dual Instance Deployment

This repository contains Terraform configuration files to deploy two AWS EC2 instances in two different availability zones (us-east-1a, us-east-1b). Both instances are balanced by a network load balancer. In addition a bash script is included to set up a Nginx web server listening to port 80 with a custom index page including the instance’s hostname.

The configuration will automatically update your ssh config file with the information of the EC2 instances to simplify developer access to the instances.

### Prerequisites

Requirements for the software and other tools to build, test and push

- Ubuntu 20.04 or any compatible os.
- An AWS account with full EC2/VPC permissions.
- A Terraform version compatible with Terraform v1.2.8.
- VScode
- Remote - SSH (vscode ext)

## Installing

You can either deploy the AWS instances and configure the web server separately, or you can use the included user_data argument to have the servers instantiated and serving all at once.

### Ready-to-serve installation

clone/download this repository

    git clone git@github.com:ferivb/Terraform_aws_ec2-nlb.git

Open main.tf with your preferred text editor and uncomment line 100

    code main.tf

Initialize Terraform

    terraform init

Apply the terraform configuration

    terraform apply -auto-approve

### Stand-alone installation

clone/download this repository

    git clone git@github.com:ferivb/Terraform_aws_ec2-nlb.git

Initialize Terraform

    terraform init

Apply the terraform configuration

    terraform apply -auto-approve

Secure copy the nginx-installer.sh script into each of the EC2 instances

    scp nginx-installer.sh ubuntu@[instance ip]:~

Ssh into the instance and execute the script

    ssh [instance ip]

    ./nginx-installer.sh

## Resources to be instantiated

- aws_vpc:
  Isolates a private segment in the cloud
- aws_subnet (us-east-1a, us-east-1b):
  Segments the VPC into different availability zones
- aws_internet_gateway:
  Opens up the VPC to external connections
- aws_route_table:
  Necessary to hold navigation routes into/from the VPC
- aws_route:
  Allows connections from an specified cidr block
- aws_route_table_association:
  Links routes with the Route table
- aws_security_group:
  Allows ssh connections and LB/instance connections
- aws_key_pair:
  Necessary to authenticate ssh connections
- aws_instance:
  EC2 instance (VM)
- aws_lb:
  Balances load between instances included in its target group
- aws_lb_target_group:
  Holds subnet information for the instances to be balanced by the LB
- aws_lb_listener:
  Listens for incoming traffic on port 80
- Aws_lb_target_group_attachment:
  Links the instances to the target group

## Authors

- **Felipe Rivas** -
  [ferivb](https://github.com/ferivb/)
