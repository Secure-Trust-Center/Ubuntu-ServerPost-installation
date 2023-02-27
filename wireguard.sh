# WireGuard VPN Hetzner Ubuntu 22.04
## https://adminforge.de/linux-allgemein/vpn/wireguard-vpn-server-mit-web-interface-einrichten/



# install WireGuard
sudo apt update && apt install -y wireguard curl tar
sudo cd /etc/wireguard

# add firewall port
ufw allow 51820/udp

# IP forwarding activate
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p

# create IP var
ip=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')

# WireGuard UI Script creation
cat <<EOF > /etc/wireguard/start-wgui.sh
#!/bin/bash

cd /etc/wireguard
./wireguard-ui -bind-address $ip:5000
EOF

# make the script executable
chmod +x start-wgui.sh

# Create Systemd Service Unit
cat <<EOF > /etc/systemd/system/wgui-web.service
[Unit]
Description=WireGuard UI

[Service]
Type=simple
ExecStart=/etc/wireguard/start-wgui.sh

[Install]
WantedBy=multi-user.target
EOF

# Create WireGuard UI download and Update Script
cat <<EOF > /etc/wireguard/update.sh
#!/bin/bash

VER=\$(curl -sI https://github.com/ngoduykhanh/wireguard-ui/releases/latest | grep "location:" | cut -d "/" -f8 | tr -d '\r')

echo "downloading wireguard-ui \$VER"
curl -sL "https://github.com/ngoduykhanh/wireguard-ui/releases/download/\$VER/wireguard-ui-\$VER-linux-amd64.tar.gz" -o wireguard-ui-\$VER-linux-amd64.tar.gz

echo -n "extracting "; tar xvf wireguard-ui-\$VER-linux-amd64.tar.gz

echo "restarting wgui-web.service"
systemctl restart wgui-web.service
EOF

# Run the WireGuard Update Script
chmod +x /etc/wireguard/update.sh
cd /etc/wireguard; ./update.sh

# WireGuard config monitor from Systemd
cat <<EOF > /etc/systemd/system/wgui.service
[Unit]
Description=Restart WireGuard
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/systemctl restart wg-quick@wg0.service

[Install]
RequiredBy=wgui.path
EOF



cat <<EOF > /etc/systemd/system/wgui.path
[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
EOF

# Service activate and start
clear
echo " Please check if the correct external ip is mentioned"
echo " at /etc/wireguard/start-wgui.sh"
cat /etc/wireguard/start-wgui.sh
echo -e "\n\n\n"
echo " please change the admin users password at"
echo " /etc/wireguard/db/server/users.json"
echo -e "\n\n\n"
echo " Restart the WebGui with systemctl restart wgui-web.service"
echo -e "\n\n\n"

