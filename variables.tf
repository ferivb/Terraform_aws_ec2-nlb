## This terraform code creates  ##
## two AWS ec2.micro instances  ##
## hosted in two different AZ   ##
## distributed by a NLB         ##
## variables are defined here   ##


variable "subnets_cidr" {
  type    = list(any)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "azs" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}