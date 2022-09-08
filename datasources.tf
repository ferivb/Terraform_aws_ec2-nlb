## This terraform code creates  ##
## two AWS ec2.micro instances  ##
## hosted in two different AZ   ##
## distributed by a NLB         ##
## datasources are defined here ##


data "aws_ami" "softserve_image" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # The last detail after - is an * for any date
  }
}

# data "aws_subnet_ids" "subnets" {
#   depends_on = [aws_subnet.subnet_public]
#   vpc_id = aws_vpc.softserve_vpc.id
# }                                             ---- deprecated

data "aws_subnets" "subnets" {
  depends_on = [aws_subnet.subnet_public]
  filter {
    name   = "vpc-id"
    values = [aws_vpc.softserve_vpc.id]
  }
}