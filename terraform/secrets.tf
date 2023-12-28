# create flag with secretsmanager


resource "aws_secretsmanager_secret" "SSTI_FLAG-TF8" {
  name                    = "SSTI_FLAG-TF8"
  description             = "flag for SSTI wargame"
  recovery_window_in_days = 0
  tags = {
  }
}

resource "aws_secretsmanager_secret_version" "SSTI_FLAG-TF8" {
  secret_id     = aws_secretsmanager_secret.SSTI_FLAG-TF8.id
  secret_string = "flag{SSGN-726}"
}