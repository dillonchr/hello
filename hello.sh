#!/bin/bash

#   INSTALL TOOLS: docker utils, git, tmux, nginx
apt install -y ufw apt-transport-https ca-certificates curl gnupg2 software-properties-common git tmux nginx vim

echo "IPV6=yes" >> /etc/ufw/ufw.conf
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow https
#   ALLOW MOSH
ufw allow 60000:61000/udp
ufw enable

#   INSTALL DOCKER
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
add-apt-repository "deb http://ftp.debian.org/debian stretch-backports main"
apt update && apt install -y docker-ce certbot

#   INSTALL CERTBOT AUTORENEW CRON
(crontab -l 2>/dev/null; echo "1 6 * * * certbot renew --post-hook \"systemctl reload nginx\"") | crontab -

#   TEST DOCKER
docker run busybox:1.24 echo "docker is up and running"

#   INSTALL DOCKER-COMPOSE
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#   TEST DOCKER-COMPOSE
docker-compose --version

#   Strong DiffieHellman
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

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
cat - > /etc/nginx/snippets/ssl-params.conf <<DHP
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
DHP
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
