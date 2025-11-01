#!/bin/bash
set -e

apt-get update -y
apt-get install -y wget tar

# install node_exporter
NODE_VER="1.6.1"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VER}/node_exporter-${NODE_VER}.linux-amd64.tar.gz
tar xzf node_exporter-${NODE_VER}.linux-amd64.tar.gz
cp node_exporter-${NODE_VER}.linux-amd64/node_exporter /usr/local/bin/
useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true

cat >/etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable --now node_exporter

echo "slave node_exporter installed"
