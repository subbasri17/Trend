terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  alias  = "Mumbai"
}

# Security Group
resource "aws_security_group" "Final" {
  name        = "Final"
  description = "Allow SSH and HTTP traffic"
  provider    = aws.Mumbai

  tags = {
    Name = "south-Final"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "trend_project1" {
  provider        = aws.Mumbai
  ami             = "ami-019715e0d74f695be"
  instance_type   = "m7i-flex.large"
  key_name        = "devops"
  vpc_security_group_ids = [aws_security_group.Final.id]

  tags = {
    Name = "Trend-Project"
  }
}
