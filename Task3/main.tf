terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server_ubu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "terraform ubuntu"
  }
  lifecycle {
    ignore_changes = [ami]
  }

  subnet_id              = aws_subnet.main_subnet_opodu.id
  vpc_security_group_ids = ["${aws_security_group.ubuntu_sg.id}"]
  key_name               = aws_key_pair.aws-key.id # the Public SSH key

  # storing the install.sh file in the EC2 instnace
  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }
  # Executing the install.sh file
  # Terraform does not reccomend this method becuase Terraform state file cannot track what the script is provissioning
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "sudo /tmp/install.sh"
    ]
  }
  # Setting up the ssh connection to install the nginx server and docker
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    agent       = true
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }
}

resource "aws_instance" "app_server_centos" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.micro"

  tags = {
    Name = "terraform centos"
  }
  lifecycle {
    ignore_changes = [ami]
  }
  subnet_id              = aws_subnet.main_subnet_opodu.id
  vpc_security_group_ids = ["${aws_security_group.centos_sg.id}"]
  key_name               = aws_key_pair.aws-key.id # the Public SSH key
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "centos"
    agent       = true
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }
}

#AMI Filter for ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


#AMI Filter for centos
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 6 x86_64 HVM EBS ENA*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["679593333241"] # amazon
}

resource "aws_vpc" "main_vpc_opodu" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink   = "false"
  instance_tenancy     = "default"
}

resource "aws_subnet" "main_subnet_opodu" {
  vpc_id                  = aws_vpc.main_vpc_opodu.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true // Makes this a public subnet
  availability_zone       = "us-east-1a"
}
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.main_vpc_opodu.id
}
resource "aws_route_table" "opodu_public_rt" {
  vpc_id = aws_vpc.main_vpc_opodu.id
  route {
    cidr_block = "0.0.0.0/0"                      // associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.prod_igw.id // CRT uses this IGW to reach internet
  }
  tags = {
    Name = "opodu_public_rt"
  }
}

resource "aws_route_table_association" "prod_crta_public_subnet_1" {
  subnet_id      = aws_subnet.main_subnet_opodu.id
  route_table_id = aws_route_table.opodu_public_rt.id
}

resource "aws_security_group" "ubuntu_sg" {
  vpc_id = aws_vpc.main_vpc_opodu.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "centos_sg" {
  vpc_id = aws_vpc.main_vpc_opodu.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "terraform_key"
  public_key = file(var.PUBLIC_KEY_PATH)
}
