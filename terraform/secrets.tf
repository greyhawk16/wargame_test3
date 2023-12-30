# create flag with secretsmanager


resource "aws_secretsmanager_secret" "SSTI_Flag" {
  name                    = "SSTI_Flag"
  description             = "flag for SSTI wargame"
  recovery_window_in_days = 0
  tags = {
  }
}

resource "aws_secretsmanager_secret_version" "SSTI_Flag" {
  secret_id     = aws_secretsmanager_secret.SSTI_Flag.id
  secret_string = "flag{SSGN-726}"
}