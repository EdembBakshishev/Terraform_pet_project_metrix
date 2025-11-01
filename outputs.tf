output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "grafana_url" {
  value = "http://${aws_instance.master.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${aws_instance.master.public_ip}:9090"
}

output "slave_private_ip" {
  value = aws_instance.slave.private_ip
}
