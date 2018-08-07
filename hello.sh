#!/bin/bash

#   INSTALL TOOLS: docker utils, git, tmux, nginx
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common git tmux nginx vim

#   INSTALL DOCKER
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
add-apt-repository "deb http://ftp.debian.org/debian stretch-backports main"
apt update && apt install -y docker-ce certbot

#   TEST DOCKER
docker run busybox:1.24 echo "docker is up and running"

#   INSTALL DOCKER-COMPOSE
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#   TEST DOCKER-COMPOSE
docker-compose --version

#   ADD USER
adduser rowsdower --gecos "Dillon Christensen,1,1,1" --disabled-password
echo "rowsdower:aliveiNtusc0n" | chpasswd
usermod -a -G sudo rowsdower

#   CONFIGURE SSH
cat - > /etc/ssh/sshd_config <<SSHD
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp  /usr/lib/openssh/sftp-server
ClientAliveInterval 120
PasswordAuthentication no

SSHD
systemctl restart ssh
su -c 'mkdir -p /home/rowsdower/.ssh' - rowsdower
su -c 'cat /git/hello/pub.keys > /home/rowsdower/.ssh/authorized_keys' - rowsdower
su -c 'chmod 600 /home/rowsdower/.ssh/authorized_keys' - rowsdower

#   INJECT HELPERS
cp ./newnginx.sh /usr/local/bin/newnginx.sh
chmod +x /usr/local/bin/newnginx.sh

#   FAREWELL!
echo "be excellent to each other"
echo "party on dudes"
