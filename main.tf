# creates EC2 instance

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


resource "tls_private_key" "this" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "this" {
  key_name      = "joonhun_SSTI_key_TF5"
  public_key    = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.this.private_key_pem}" > joonhun_SSTI_key_TF5.pem
    EOT
  }
}


resource "aws_security_group" "alone_web" {
  name        = "Alone EC2 Security Group"
  description = "Alone EC2 Security Group"
  ingress {
    from_port = 22                                           
    to_port = 22                                             
    protocol = "tcp"                                         
    cidr_blocks = ["0.0.0.0/0"]       
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "app_server" {
  ami = "ami-079db87dc4c10ac91"  # AMI from "joonhun_SSTI_rev3"
  instance_type = "t3.micro"
  key_name = "${aws_key_pair.this.key_name}"
  vpc_security_group_ids = ["${aws_security_group.alone_web.id}"] # ["sg-0f1333e985b024d83"]
  
  tags = {
    Name = "joonhun_ExampleAppServerInstance-TF5"
  }
  root_block_device {
    volume_size         = 30 
  }
}

# EIP
resource "aws_eip" "elasticip" {
  instance = aws_instance.app_server.id
}

output "EIP" {
  value = aws_eip.elasticip.public_ip
}
