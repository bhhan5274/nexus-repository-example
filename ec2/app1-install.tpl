#!/bin/sh

set -e

sudo yum update -y
sudo mkdir -p ${efs_mount_point}
sudo yum -y install amazon-efs-utils
sudo su -c  "echo '${file_system_id}:/ ${efs_mount_point} efs _netdev,tls 0 0' >> /etc/fstab"
sudo mount ${efs_mount_point}
df -k

sudo yum -y install wget
sudo yum -y install java-1.8.0-amazon-corretto.x86_64

if [ ! -d "/nexus/nexus-3" ]; then
    sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
    sudo tar -xvf nexus.tar.gz
    sudo mv nexus-3* nexus-3
    sudo mv nexus-3 /nexus
    sudo mv sonatype-work /nexus
    sudo bash -c 'cat <<EOF > /nexus/nexus-3/bin/nexus.rc
run_as_user="nexus"
EOF'
fi

sudo adduser nexus
sudo chown -R nexus:nexus /nexus/nexus-3
sudo chown -R nexus:nexus /nexus/sonatype-work

sudo bash -c 'cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/nexus/nexus-3/bin/nexus start
ExecStop=/nexus/nexus-3/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF'

sudo chkconfig nexus on
sudo systemctl start nexus
