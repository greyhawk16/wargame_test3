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
resource "aws_iam_role" "test_role" {
  name               = "joonhun_SSTI_STS_role-TF2"
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

# STS 작업 허용용
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
          생
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.cg-ec2-instance-profile.name}"

  tags = {
    Name = "ExampleAppServerInstance-2"
  }

  # role = "${aws_iam_role.test_role.name}"
}
