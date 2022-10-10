resource "aws_config_config_rule" "restricted-ssh" {
  name        = "restricted-ssh"
  description = "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
    }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
}