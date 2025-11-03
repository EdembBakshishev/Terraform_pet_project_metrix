variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for deployment"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Instance type for EC2 instances"
}

variable "key_name" {
  type        = string
  description = "Existing AWS key pair name for SSH access"
}

variable "allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR range allowed to access instances"
}
