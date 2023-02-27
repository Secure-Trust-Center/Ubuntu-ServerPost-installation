#!/bin/bash

clear
print -p "This will install your basic Server settings"

# update and upgrade Distro
sudo apt update
sudo apt upgrade

# Add user
adduser imperator

# Add imperator to sudoers
echo "imperator ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Customize
mkdir /home/imperator/.ssh
cp /root/.ssh/authorized_keys /home/imperator/.ssh/authorized_keys
chmod 755 /home/imperator/.ssh
chmod 600 /home/imperator/.ssh/authorized_keys
chown imperator:imperator /home/imperator/.ssh/authorized_keys

# Customize SSH 
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.org
# nano /etc/ssh/sshd_config
# sshd_config
echo -e "Port 22" >> /etc/ssh/sshd_config
echo "LoginGraceTime 30s" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "MaxAuthTries 2" >> /etc/ssh/sshd_config
echo "MaxSessions 2" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "PrintMotd no" >> /etc/ssh/sshd_config
echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
echo "Subsystem       sftp    /usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config

# Add the SSH Banner
echo -e "########################################################\n
#                                                      #\n
#                                                      #\n
#   UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED   #\n
#                                                      #\n
#   You must have explicit, authorized permission to   #\n
#     access or configure this device. Unauthorized    #\n
#   attempts and actions to access or use this system  #\n
#     may result in civil and/or criminal penalties.   #\n
#      All activities performed on this device are     #\n
#                logged and monitored.                 #\n
#                                                      #\n
########################################################" >> /etc/ssh/banner


# Secure Installation

## Install & Config UFW
apt install ufw
ufw allow ssh
ufw eneable

## fail2ban
sudo apt install fail2ban
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl status fail2ban.service
 
## restarting SSH Server
systemctl restart sshd

