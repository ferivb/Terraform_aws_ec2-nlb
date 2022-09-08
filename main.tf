## This terraform code creates  ##
## two AWS ec2.micro instances  ##
## hosted in two different AZ   ##
## distributed by a NLB         ##
## Resources are defined here   ##


# -------  VPC -----------
resource "aws_vpc" "softserve_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = "true" # support assigning public DNS hostnames to instances with public IP addresses.
  enable_dns_support   = "true" # supports DNS resolution through the Amazon provided DNS server.

  tags = {
    Name = "softserve_vpc"
  }
}

# ------- SUBNETS -----------
resource "aws_subnet" "subnet_public" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.softserve_vpc.id
  cidr_block              = element(var.subnets_cidr, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "Subnet-AZ-${count.index + 1}"
  }
}

# ------- GATEWAY -----------
resource "aws_internet_gateway" "softserve_gw" {
  vpc_id = aws_vpc.softserve_vpc.id

  tags = {
    Name = "softserve_internet_gateway"
  }
}

# ------- ROUTE TABLE -----------
resource "aws_route_table" "softserve_rt" {
  vpc_id = aws_vpc.softserve_vpc.id

  tags = {
    Name = "softserve_route_table"
  }
}

# ------- ROUTE -----------
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.softserve_rt.id
  destination_cidr_block = "0.0.0.0/0" # All internet addresses can connect
  gateway_id             = aws_internet_gateway.softserve_gw.id
}

# ------- RT/ROUTE ASSOCIATION -----------
resource "aws_route_table_association" "softserve_rt_assoc" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.subnet_public.*.id, count.index)
  route_table_id = aws_route_table.softserve_rt.id
}

# ------- SECURITY GROUP -----------
# allows ssh connections and LB/instance connections
resource "aws_security_group" "softserve_security_group" {
  name        = "softserve_sg"
  description = "softserve security group"
  vpc_id      = aws_vpc.softserve_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 is all protocols, 6 (TCP), 17 (UDP), and 1 (ICMP)
    cidr_blocks = ["0.0.0.0/0"] # Personal IP goes here with /32 at the end
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow it to access the open internet
  }
}

# ------- SSH KEY -----------
resource "aws_key_pair" "softserve_key" {
  key_name   = "softserve_key"
  public_key = file("~/.ssh/softserve_test.pub")
}

# ------- EC2 INSTANCES -----------
resource "aws_instance" "softserve_node" {
  count                  = length(var.subnets_cidr)
  instance_type          = "t2.micro" #750 hrs free p/month
  ami                    = data.aws_ami.softserve_image.id
  key_name               = aws_key_pair.softserve_key.id
  vpc_security_group_ids = [aws_security_group.softserve_security_group.id]
  subnet_id              = element(aws_subnet.subnet_public.*.id, count.index)
  # user_data              = file("nginx-installer.sh")  --- two scenarios in one

  root_block_device {
    volume_size = 10 # (HD in Gbs) - Default size is 8, free tier ends at 16
  }

  tags = {
    Name = "Node-AZ-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = templatefile("ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/softserve_test"
    })
    interpreter = ["bash", "-c"]
  }
}

# ------- LOAD BALANCER (NLB) -----------
resource "aws_lb" "softserve-nlb" {
  name               = "softserve-network-load-balancer"
  load_balancer_type = "network"
  subnets            = data.aws_subnets.subnets.ids
  # subnets            = data.aws_subnet_ids.subnets.ids --- deprecated

}

# ------- LB TARGET GROUP -----------
# Group to be targeted by the LB
resource "aws_lb_target_group" "softserve_tg" {
  name     = "softserve-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.softserve_vpc.id
}

# ------- LB LISTENER -----------
resource "aws_lb_listener" "softserve_listener" {
  load_balancer_arn = aws_lb.softserve-nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.softserve_tg.arn
  }
}

# ------- TG ATTATCHMENTS -----------
# adds the instances as targets to the TG
resource "aws_lb_target_group_attachment" "softserve_tg_att" {
  count            = length(var.subnets_cidr)
  target_group_arn = aws_lb_target_group.softserve_tg.arn
  target_id        = element(aws_instance.softserve_node.*.id, count.index)
  port             = 80
}