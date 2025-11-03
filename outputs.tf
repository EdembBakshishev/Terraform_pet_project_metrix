output "master_public_ip" {
  value = module.master.public_ip
}

output "slave_private_ip" {
  value = module.slave.private_ip
}

output "grafana_url" {
  value = "http://${module.master.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${module.master.public_ip}:9090"
}
