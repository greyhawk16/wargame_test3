terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

# role 생성
resource "aws_iam_role" "test_role" {
  name               = "joonhun_SSTI_STS_role-TF7"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}


# STS 관련 policy 생성
resource "aws_iam_role_policy" "hello_sts" {
  name   = "joonhun_SSTI_STS-TF7"
  role   = aws_iam_role.test_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sts:GetSessionToken",
                "sts:DecodeAuthorizationMessage",
                "sts:GetAccessKeyInfo",
                "sts:GetCallerIdentity",
                "sts:AssumeRole",
                "sts:GetServiceBearerToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "sts:*",
            "Resource": "arn:aws:iam::405607210241:role/joonhun_SSTI_role"
        }
    ]
}
EOF
}

# iamReadOnly 정책 생성
resource "aws_iam_role_policy" "iamReadOnly" {
  name   = "joonhun_IAMReadOnly-TF7"
  role   = aws_iam_role.test_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:Get*",
                "iam:List*",
                "iam:SimulateCustomPolicy",
                "iam:SimulatePrincipalPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# EC2 인스턴스 프로필 생성
resource "aws_iam_instance_profile" "joonhun_EC2_profile-TF7" {
  name = "joonhun_EC2_profile-TF7"
  role = "${aws_iam_role.test_role.name}"
}



resource "tls_private_key" "this" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "this" {
  key_name      = "joonhun_SSTI_key_TF7"
  public_key    = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.this.private_key_pem}" > joonhun_SSTI_key_TF7.pem
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
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "app_server" {
  ami = "ami-079db87dc4c10ac91"  # AMI from "joonhun_SSTI_rev3"
  instance_type = "t3.micro"
  key_name = "${aws_key_pair.this.key_name}"
  vpc_security_group_ids = ["${aws_security_group.alone_web.id}"] # ["sg-0f1333e985b024d83"]
  iam_instance_profile = "${aws_iam_instance_profile.joonhun_EC2_profile-TF7.name}"

  user_data = <<-EOF
        #!/bin/bash
        sudo yum update
        sudo yum install git -y
        sudo yum install pip -y
        git clone https://github.com/greyhawk16/wargame_test3.git
        EOF
  
  tags = {
    Name = "joonhun_ExampleAppServerInstance-TF7"
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
