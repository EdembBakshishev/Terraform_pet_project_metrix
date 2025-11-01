data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# resource "aws_key_pair" "user" {
#   count      = var.public_key_path != "" ? 1 : 0
#   key_name   = var.key_name
#   public_key = file(var.public_key_path)
# }

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Allow SSH, node_exporter, Prometheus, Grafana"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  # allow Prometheus to scrape node_exporter (internal)
  ingress {
    description = "node_exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Master instance (Prometheus + Grafana + node_exporter)
resource "aws_instance" "master" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.monitoring_sg.name]

  user_data = templatefile("${path.module}/templates/master_user_data.tpl", {
    slave_private_ip = aws_instance.slave.private_ip
    NODE_VER         = "1.6.1"
    PROM_VER         = "2.45.0"
  })

  tags = {
    Name = "monitoring-master"
  }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "echo destroying master"
  # }
}

# Slave instance (only node_exporter)
resource "aws_instance" "slave" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.monitoring_sg.name]

  user_data = file("${path.module}/templates/slave_user_data.sh")

  tags = {
    Name = "monitoring-slave"
  }
}

# small delay to ensure slave IP available for master template — we rely on templatefile using aws_instance.slave.private_ip
# NOTE: terraform will compute slave before master because master references slave.private_ip

