#!/usr/bin/env bash
set -e

# Install packages
sudo apt-get update -y
sudo apt-get install -y curl unzip

# Download Vault into some temporary directory
curl -L "${download_url}" > /tmp/vault.zip

# Unzip it
cd /tmp
sudo unzip vault.zip
sudo mv vault /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

mkdir /etc/vault.d
# Setup the configuration
cat <<EOF >/etc/vault.d/vault-config.json
backend "consul" {
  address = "${consul}:8500"
  path = "vault"
}
listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = 1
}
disable_mlock = false
EOF

# Setup the init script
cat << 'EOF' > /etc/systemd/system/vault.service
[Unit]
Description=vault agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/vault
Restart=on-failure
ExecStart=/usr/local/bin/vault server $OPTIONS -config=/etc/vault.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

# Start Vault
systemctl enable vault.service
systemctl start vault.service
