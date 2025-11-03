resource "aws_instance" "this" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.security_group_name]
  user_data       = var.user_data

  tags = merge(
    {
      Name = var.name
    },
    var.additional_tags
  )
}
