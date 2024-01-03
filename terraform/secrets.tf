# create flag with secretsmanager


resource "aws_secretsmanager_secret" "cr-SSTI-flag" {
  name                    = "cr-SSTI-flag"
  description             = "flag for SSTI wargame"
  recovery_window_in_days = 0
  tags = {
  }
}

resource "aws_secretsmanager_secret_version" "cr-SSTI-flag" {
  secret_id     = aws_secretsmanager_secret.cr-SSTI-flag.id
  secret_string = "flag{SSGN-726}"
}