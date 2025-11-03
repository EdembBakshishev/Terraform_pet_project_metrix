locals {
  project_name          = "monitoring"
  environment           = "dev"
  node_exporter_version = "1.6.1"
  prometheus_version    = "2.45.0"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    },
    {
      description = "Grafana"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
    },
    {
      description = "Prometheus"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
    },
    {
      description = "node_exporter"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
    }
  ]
}
