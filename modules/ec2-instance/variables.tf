variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "security_group_name" { type = string }
variable "user_data" { type = string }
variable "name" { type = string }
variable "additional_tags" {
  type    = map(string)
  default = {}
}
