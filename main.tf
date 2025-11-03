# Lookup latest Ubuntu AMI
module "ami" {
  source = "./modules/ami"
}

# Security Group
module "monitoring_sg" {
  source        = "./modules/security-group"
  name          = "${local.project_name}-sg"
  description   = "Allow SSH, Prometheus, Grafana, node_exporter"
  allowed_cidr  = var.allowed_cidr
  ingress_rules = local.ingress_rules
  tags          = local.common_tags
}

# Slave instance
module "slave" {
  source              = "./modules/ec2-instance"
  ami_id              = module.ami.id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_group_name = module.monitoring_sg.name
  user_data           = file("${path.module}/templates/slave_user_data.sh")
  name                = "${local.project_name}-slave"
  additional_tags     = local.common_tags
}

# Master instance
module "master" {
  source              = "./modules/ec2-instance"
  ami_id              = module.ami.id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_group_name = module.monitoring_sg.name
  user_data = templatefile("${path.module}/templates/master_user_data.tpl", {
    slave_private_ip = module.slave.private_ip
    NODE_VER         = local.node_exporter_version
    PROM_VER         = local.prometheus_version
  })
  name            = "${local.project_name}-master"
  additional_tags = local.common_tags
}
