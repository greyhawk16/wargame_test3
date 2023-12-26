# terraform init
# terraform validate
# terraform apply


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = "us-west-2"
}

# STS 관련 role 생성
resource "aws_iam_role_policy" "hello_sts" {
  name   = "joonhun_SSTI_STS-TF2"
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

# iamReadOnly 정책 생성성
resource "aws_iam_role_policy" "iamReadOnly" {
  name   = "joonhun_IAMReadOnly-TF1"
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
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile"
  role = "${aws_iam_role.test_role.name}"
}

# EC2 인스턴스 생성
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.cg-ec2-instance-profile.name}"

  tags = {
    Name = "ExampleAppServerInstance-2"
  }

  # role = "${aws_iam_role.test_role.name}"
}
