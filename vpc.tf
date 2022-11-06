# provider - aws and region
provider "aws" {
  region  = var.region
}

# create a custom vpc
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy

  tags = {
    Name = var.vpc_name
  }
}

### tier #1 - web tier
# create an internet gateway to connect vpc with internet
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.terraform_vpc.id
}

# create a public subnet #1
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = var.public_subnet_cidr_block_1

  tags = {
    Name = var.public_subnet_name_1
  }
}

# create a public route table #1

resource "aws_route_table" "public_subnet_1_to_internet" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = var.public_route_table_1
  }
}

# make a route table connection in between public route table #1 with public subnet #1

resource "aws_route_table_association" "internet_for_public_subnet_1" {
  route_table_id = aws_route_table.public_subnet_1_to_internet.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
#create a 2019 webserver in public subnet 1 

resource "ec2_instance" " ec2_public" {
  source  = "ec2-instance/aws"
  instance_type          = "${var.instance_type}"
  name                   = "bastion 1"
  security_groups        = ["${aws_security_group.ssh-security-group.id}"]
  subnet_id              = "${aws_subnet.public-subnet-1.id}"
  ami                    = "ami-026bb75827bd3d68d"
  key_name               = "aimeefoster"
  monitoring             = true
  
}

# create a public subnet #2
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = var.public_subnet_cidr_block_2

  tags = {
    Name = var.public_subnet_name_2
  }
}

# create a public route table #2
resource "aws_route_table" "public_subnet_2_to_internet" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = var.public_route_table_2
  }
}

# make a route table connection in between public route table #2 with public subnet #2
resource "aws_route_table_association" "internet_for_public_subnet_2" {
  route_table_id = aws_route_table.public_subnet_2_to_internet.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
# create a RHEL instance in WP Subnet 2 

#Create a new EC2 launch configuration
resource "aws_instance" "ec2_public" {
ami                    = "ami-0eb7496c2e0403237"
instance_type               = "${var.instance_type}"
key_name                    = "${var.key_name}"
security_groups             = ["${aws_security_group.ssh-security-group.id}"]
subnet_id                   = "${aws_subnet.public-subnet-1.id}"
associate_public_ip_address = true
lifecycle {
create_before_destroy = true
}
tags = {
"Name" = "wpserver2"
}
# Copies the ssh key file to home dir
provisioner "file" {
source      = "./${var.key_name}.pem"
destination = "/home/ec2-user/${var.key_name}.pem"
connection {
type        = "ssh"
user        = "ec2-user"
private_key = file("${var.key_name}.pem")
host        = self.public_ip
}
}
//chmod key 400 on EC2 instance
provisioner "remote-exec" {
inline = ["chmod 400 ~/${var.key_name}.pem"]
connection {
type        = "ssh"
user        = "ec2-user"
private_key = file("${var.key_name}.pem")
host        = self.public_ip
}
}
}
#Create a new EC2 launch configuration
resource "aws_instance" "ec2_private" {
#name_prefix                 = "terraform-example-web-instance"
ami                         = "ami-06640050dc3f556bb "
instance_type               = "${var.instance_type}"
key_name                    = "${var.key_name}"
security_groups             = ["${aws_security_group.webserver-security-group.id}"]
subnet_id                   = "${aws_subnet.private-subnet-1.id}"
associate_public_ip_address = false

lifecycle {
create_before_destroy = true
}
tags = {
"Name" = "WPserver2"
}
}

### tier #2 - app tier
# create a private subnet #1
resource "aws_subnet" "private_subnet_1" {
  cidr_block = var.private_subnet_cidr_block_1
  vpc_id = aws_vpc.terraform_vpc.id
  availability_zone = var.private_subnet_1_az

  tags = {
    Name = var.tagkey_name_private_subnet_1
  }
}

# create an EIP for windows server 2019
resource "aws_eip" "eip_1" {
  count = "1"
}

resource "public subnet 1" "public subnet 1" {
  count = "1"
  allocation_id = aws_eip.eip_1[count.index].id
  subnet_id = aws_subnet.public_subnet_1.id
}

# create a private route table #1
resource "aws_route_table" "aws route_table" {
  count  = "1"
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = var.tagkey_private_route_table_1
  }
}

# make a route table connection in between private route table #1 with private subnet #1
resource "aws_route_table_association" "private_subnet_1" {
  count          = "1"
  route_table_id = aws_route_table._1[count.index].id
  subnet_id      = aws_subnet.private_subnet_1.id
}

## ensure high availability of app tier

# create a private subnet #2
resource "aws_subnet" "private_subnet_2" {
  cidr_block = var.private_subnet_cidr_block_2
  vpc_id = aws_vpc.terraform_vpc.id
  availability_zone = var.private_subnet_2_az

  tags = {
    Name = var.tagkey_name_private_subnet_2
  }
}

resource "private_subnet_2" "private_subnet_2" {
  count = "1"
  allocation_id = aws_eip.eip_2[count.index].id
  subnet_id = aws_subnet.public_subnet_2.id
}

# create a private route table #2
resource "aws_route_table" "nategateway_route_table_2" {
  count  = "1"
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = var.tagkey_private_route_table_2
  }
}

# make a route table connection in between private route table #2 with private subnet #2 
resource "aws_route_table_association" "private_subnet_2" {
  count          = "1"
  route_table_id = aws_route_table._2[count.index].id
  subnet_id      = aws_subnet.private_subnet_2.id
}

### tier #3 - Postgres SQL11 database tier
# create a private subnet #3
resource "aws_subnet" "private_subnet_3" {
  cidr_block = var.private_subnet_cidr_block_3
  vpc_id = aws_vpc.terraform_vpc.id
  availability_zone = var.private_subnet_3_az

  tags = {
    Name = var.tagkey_name_private_subnet_3
  }
}

resource "private_subnet_3" "private_subnet_3" {
  count = "1"
  subnet_id = aws_subnet.private_subnet_3.id
}

# create a private route table #3
resource "aws_route_table" "aws_route_table" {
  count  = "1"
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = var.tagkey_name_name_private_route_table_3
  }
}

# make a route table connection in between private route table #3 with private subnet #3

resource "aws_route_table_association" "private_subnet_3" {
  count          = "1"
  route_table_id = aws_route_table.route_table_3[count.index].id
  subnet_id      = aws_subnet.private_subnet_3.id
}

## ensure high availability of database tier
# create a private subnet #4
resource "aws_subnet" "private_subnet_4" {
  cidr_block = var.private_subnet_cidr_block_4
  vpc_id = aws_vpc.terraform_vpc.id
  availability_zone = var.private_subnet_4_az

  tags = {
    Name = var.tagkey_name_private_subnet_4
  }
}

resource "aws_subnet" "private_subnet_4" {
  count = "1"
  subnet_id = aws_subnet.private_subnet_4.id
}

# create a private route table #4
resource "aws_route_table" "route_table_4" {
  count  = "1"
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = var.tagkey_name_route_table_4
  }
}

# make a route table connection in between private route table #4 with private subnet #4
resource "aws_route_table_association" "private_subnet_4" {
  count          = "1"
  route_table_id = aws_route_table._4[count.index].id
  subnet_id      = aws_subnet.private_subnet_4.id
}


### EC2 information
# Create a keypair
resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.public_key.public_key_openssh
}

# Create postgreSQL 11 DB
module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "postgreSQL11"
  instance_class    = "db.t3a.micro"
  allocated_storage = 5

  db_name  = "RDS1"
  username = "user"
  port     = "3306"

  }

# Create subnet 3
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]

  tags = {
    Name = "RDS subnet group"
  }
}

### ALB information
# Create an ALB 
resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Environment  = var.alb_tagname
  }
}

### shared Security Group 
# Create a shared security group 
resource "aws_security_group" "alb_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = var.rds_from_port
    to_port     = var.rds_to_port
    protocol    = "tcp"
    description = "postgres"
    self        = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    self        = true
  }

  egress {
    from_port        = var.sg_egress_from_port
    to_port          = var.sg_egress_to_port
    protocol         = var.sg_egress_protocol
    cidr_blocks      = var.sg_egress_cidr_blocks
  }

  tags = {
    Name = var.sg_tagname
  }
}