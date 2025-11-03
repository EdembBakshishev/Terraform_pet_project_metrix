variable "name" { type = string }
variable "description" { type = string }
variable "allowed_cidr" { type = string }
variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
}
variable "tags" {
  type    = map(string)
  default = {}
}
