#!/bin/bash

read -p "shadowsocks password: " pwd
read -p "server port: " port

apt install -y shadowsocks-libev simple-obfs

(
cat << EOF
{
    "server":"0.0.0.0",
    "server_port":${port},
    "local_port":1080,
    "password":"${pwd}",
    "timeout":60,
    "method":"chacha20-ietf-poly1305",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=tls;failover=127.0.0.1:${port}"
}
EOF
) > /etc/shadowsocks-libev/config.json

systemctl start shadowsocks-libev

# Windows client
# 插件程序：obfs-local
# 插件选项：obfs=tls;obfs-host=www.baidu.com