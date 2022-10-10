terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  profile                 = "sandbox"
  shared_credentials_files  = ["../.aws/credentials"]
}

resource "aws_vpc" "main"{
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "allow_open_ssh" {
  name        = "allow_open_ssh"
  description = "Allow SSH inbound traffic from any"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from Any"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }
 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "aws_instance" "ssh1" {
 ami                         = "${data.aws_ami.amazon-linux-2.id}"
 associate_public_ip_address = true
 instance_type               = "t2.micro"
 subnet_id = aws_subnet.public.id
 vpc_security_group_ids = [aws_security_group.allow_open_ssh.id]
}

