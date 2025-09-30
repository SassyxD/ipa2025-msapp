
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = ""
  secret_key = ""
  token = ""
  region     = "us-east-1"
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter { 
          name = "name"                 
          values = ["amzn2-ami-hvm-*-x86_64-gp2"] 
  }
  filter { 
          name = "virtualization-type"  
          values = ["hvm"] 
  }
  filter { 
          name = "root-device-type"     
          values = ["ebs"] 
  }
}

##################################################################################
# Ref
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/
##################################################################################
# RESOURCES
##################################################################################

resource "aws_vpc" "test" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags ={
        Name = "testVPC"
    }
}

resource "aws_subnet" "public1" {
    vpc_id                  = aws_vpc.test.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true

    tags ={
        Name = "Public1"
    }
}

resource "aws_security_group" "allow_ssh_web" {
  name        = "AllowSSHandWeb"
  description = "Allow ssh and web access"
  vpc_id      = aws_vpc.test.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "AllowSSHandWeb" }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_web.id]
  key_name               = "vockey"     # ใช้ key pair ชื่อนี้

  # ดิสก์ระบบ 8GB gp2
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = { Name = "tfTest" }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.test.id

    tags ={
        Name = "testIgw"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test.id
  tags   = { Name = "testVPC-public-rt" }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}


##################################################################################
# OUTPUT
##################################################################################

output "public_ip"  { value = aws_instance.web.public_ip }
output "public_dns" { value = aws_instance.web.public_dns }