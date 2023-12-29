# EC2 role 생성
resource "aws_iam_role" "test_role" {
  name               = "joonhun_SSTI_STS_role-TF8"
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


# iamReadOnly 정책 생성
resource "aws_iam_role_policy_attachment" "iamReadOnly" {
  role   = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}


# EC2 인스턴스 프로필 생성
resource "aws_iam_instance_profile" "joonhun_EC2_profile-TF8" {
  name = "joonhun_EC2_profile-TF8"
  role = "${aws_iam_role.test_role.name}"
}



resource "tls_private_key" "this" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "this" {
  key_name      = "joonhun_SSTI_key_TF8"
  public_key    = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.this.private_key_pem}" > joonhun_SSTI_key_TF8.pem
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
  iam_instance_profile = "${aws_iam_instance_profile.joonhun_EC2_profile-TF8.name}"
  
  tags = {
    Name = "joonhun_ExampleAppServerInstance-TF8"
  }
  root_block_device {
    volume_size         = 30 
  }
  provisioner "file" {
      source = "../code"
      destination = "/home/ec2-user/code"
      connection {
        type = "ssh"
        user = "ec2-user"
        host = self.public_ip
        private_key = "${file(var.ssh-private-key-for-ec2)}"
      }
  }


  user_data = <<-UD
        #!/bin/bash
        sudo yum update
        sudo yum install git -y
        sudo yum install pip -y
        sudo yum install nc -y
        pip3 install flask
        cd ./code
        sudo python3 ./app.py
        UD
}

# EIP
resource "aws_eip" "elasticip" {
  instance = aws_instance.app_server.id
}
