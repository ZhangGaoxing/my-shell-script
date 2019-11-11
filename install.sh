#!/bin/bash

# Raspbian 切换源
mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ stretch main non-free contrib" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ stretch main non-free contrib" >> /etc/apt/sources.list
mv /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" > /etc/apt/sources.list.d/raspi.list

# Debian 切换源
# mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
#     echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch main contrib non-free" > /etc/apt/sources.list && \
#     echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch-backports main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ stretch-backports main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list

apt update
apt upgrade -y

# 安装 vsftp
apt install -y vsftpd
echo "write_enable=YES" >> /etc/vsftpd.conf
service vsftpd restart

# 安装 .NET Core Runtime
wget https://download.visualstudio.microsoft.com/download/pr/0c5e013b-fa57-44dc-85bf-746885181278/58647e532fcc3a45209c13cdfbf30c74/dotnet-runtime-3.0.0-linux-arm.tar.gz
# wget https://download.visualstudio.microsoft.com/download/pr/707fd000-c376-40de-9862-cabc46a344ec/82e0a3c816247bad4563c3e74655f7cf/dotnet-runtime-3.0.0-linux-arm64.tar.gz
mkdir dotnet3 && tar -xvf dotnet-runtime-3.0.0-linux-arm.tar.gz -C dotnet3
ln -s dotnet3/dotnet /usr/bin/dotnet

# 安装 Docker
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb [arch=armhf] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce
groupadd docker
usermod -aG docker $USER
touch /etc/docker/daemon.json
echo "{\"registry-mirrors\": [\"https://dockerhub.azk8s.cn\",\"https://reg-mirror.qiniu.com\"]}" > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

# 安装 PostgreSQL
apt install -y postgresql-11
echo "listen_addresses = '*'" >> /etc/postgresql/11/main/postgresql.conf
echo "password_encryption = md5" >> /etc/postgresql/11/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/11/main/pg_hba.conf
/etc/init.d/postgresql restart