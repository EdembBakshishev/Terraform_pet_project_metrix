variable "aws_region" {
  type    = string
  default = "us-east-1" # change if you want
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing AWS key pair name to use for SSH"
}

variable "public_key_path" {
  type        = string
  default     = "key.pem"
  description = "Optional path to a local public key to create a key pair. Leave empty if using existing key_name."
}

variable "allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR allowed to access Grafana (3000). Use a narrow CIDR in production."
}
