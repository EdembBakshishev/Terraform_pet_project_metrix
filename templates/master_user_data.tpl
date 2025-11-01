#!/bin/bash
set -e

# update
apt-get update -y
apt-get install -y wget tar apt-transport-https software-properties-common gnupg

# --------------------
# install node_exporter
# --------------------
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

# --------------------
# install Prometheus
# --------------------
PROM_VER="2.45.0"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz
tar xzf prometheus-${PROM_VER}.linux-amd64.tar.gz
mv prometheus-${PROM_VER}.linux-amd64 /opt/prometheus

useradd --no-create-home --shell /usr/sbin/nologin prometheus || true
mkdir -p /etc/prometheus /var/lib/prometheus
cp /opt/prometheus/prometheus /usr/local/bin/
cp /opt/prometheus/promtool /usr/local/bin/
cp -r /opt/prometheus/consoles /etc/prometheus
cp -r /opt/prometheus/console_libraries /etc/prometheus

# create prometheus.yml with both targets (master + slave)
cat >/etc/prometheus/prometheus.yml <<EOPY
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100', '${slave_private_ip}:9100']
EOPY

chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
chmod +x /usr/local/bin/prometheus

cat >/etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus

# --------------------
# install Grafana
# --------------------
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt-get update -y
apt-get install -y grafana

systemctl enable --now grafana-server

# Done
echo "Setup finished"
