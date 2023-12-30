# 공격자가 취득해야 하는 role
resource "aws_iam_role" "secret_role" {
  name               = "SSTI_secret_role"
  path               = "/"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
  }
  EOF
}

# SSTI_secret_role에 붙일 policy
resource "aws_iam_role_policy_attachment" "secretsmanager_policy" {
  role   = aws_iam_role.secret_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}