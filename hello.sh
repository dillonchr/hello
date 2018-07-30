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
su -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1kL2ttwZ+Yx6w9GjF8j9z2A/H8IMG3cd4KK/93FudO4pybTfWa+SRp/lQ0Vjit/fYk5gvpUeddmpoaj3MgZWIwJBHXPA20RIuYiHmuTlVVKDCWFfwPFAArrL57M9DUDWQuFlzvLIT/+2pn29gY6TPNhDZRBg8WK0rAjRG8qYet0MyiX1OJkoEOgIfqtqUwQg16nxSzlh7q0gsPzpkK+LlprJorqMC7d0ZuoNEaO/rf4NKHgOsRz17WT6Mp35AhGxdi80jkf0dYUcPi0fO4TEQYj6pYfid71PRAH7ROmBQEFa7+Pd/LeI4KAQtCT+OKB2pQYdrjOqF/o5bcRYBM2kT ChristensenD@NBTUL2089\
\
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6b3W2sfxif2V5fW0XrmUj8HLNuo1kZQrHaLX6DoqCw64aor4C8cEudJYfFujmvf43Itm44MasvdrAQ1gpnZQXCoxb+qw0/XKvrMOPdiBPo4jFZYzszvWhV1yRijkhGCTpucUOFB0wYkQjT5gmGS7S8zyt+TJBd8dQh1DIYMuaXX8DuxEE3z+PQGTWCXOBtRJA7uf5+68d+cjOJBpz8DNuxwvLEi6PztHTVfB2w1hBwHW/JB59dviXm392DHLew2JpxpEAo0QqUKPRiQNwIFDnvUXvxow4HfwyLiaoxcQJk55kaFHYifXEUH3fF7rG7TBqzkD4K+/SOteky6FO3G4H kowalski@maridia\
\
sh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAd/jGfO+ay+jEo4WHpjLEDwuqqwEi2QID5ETyYEIe4Dj5b7Pyc0Jg4AovG+aHMTscIsqBPuRPWSRjlB+a3pHDalwM2f5Hqp5xKWE/LbCfyOgXpJXlB80j6bs67cEhC8xgJsXz+5f9EzxIMuWUONPEQzgOWVidN78P5dnRUD0NklU2eA/LBkw4nFXBEi3iDFt/sFWqADMj1rI8mCCTsEkUJNc4M4R+AGNnbzwJ1sO1R1+89Bw3vqvKGsAlPnCDMg6C7hF49DeHUDoN7a0JESzQwJ3+AYrrNyn9V46C3oa4G8XqIIzv1Y9UEGHiCbcYxzITtYBSmHZBUp+ySyJInhb7 kowalski@Shasta\
\
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC61q6+h8lV0gSPGENJczl35uIF6SKn5ikeFr7Vf8ARbuMDR/5lWYNdjuvn921qSwLBnlc6EMFo7EyQemxDOOXTuPyJMu7h6r6mNvq9cTLqIULO70oTe320zNFWL/IxvtGpNhUHRbv9Z3hIzsgkOTd9NC+rThWveQPzugTYnB94ID/KTrn5iRsjVTp0pxzGAzxctSxrTh+kcxVIelDf1GCW03YCP+cZRAdAiqxXNF77kLTS0tMB+4gU+bUTqlxGgZHaNV14AQU0ChZBJgWkdBOj2so3R5OHY1UvX56CkuDeHn/dwUgdaRTaAwMDTEZU5N1qV2mc5lhdgl+Njo9Z3mtF u0_a142@localhost\
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCl+xUC0xIcNT0RmG1x338MFDD0riX12+hQFAd5KQgZ+kYzHhjDUdEWXZ+QcDZlc7FWmQHRcxsxmVOZkBU7HdJbPba8dWZmmFCZNGq9EYPIb0+s1jCITxfkDxfQjGV1Xu6T3MbmgqtsdVYxXXzCASRe2cuINKlYpqrh1uzhL92Ff6/C2dZ8wqpJfyjlJOTTzK5/C2nkhuHVTAMuuzJPDcppr+gEgqpo+yzNwx+6RQVbG2Y1Z12ReZPbpRJMAEJcE64g3qTMR8H00pFY/GuwpJlbT2ckt+qwBm08/buOl18iJd7R42xfpVFnNbDai/+OH5caMmNRN6TR5D2eLQih4425 u0_a20@localhost\
\
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6b3W2sfxif2V5fW0XrmUj8HLNuo1kZQrHaLX6DoqCw64aor4C8cEudJYfFujmvf43Itm44MasvdrAQ1gpnZQXCoxb+qw0/XKvrMOPdiBPo4jFZYzszvWhV1yRijkhGCTpucUOFB0wYkQjT5gmGS7S8zyt+TJBd8dQh1DIYMuaXX8DuxEE3z+PQGTWCXOBtRJA7uf5+68d+cjOJBpz8DNuxwvLEi6PztHTVfB2w1hBwHW/JB59dviXm392DHLew2JpxpEAo0QqUKPRiQNwIFDnvUXvxow4HfwyLiaoxcQJk55kaFHYifXEUH3fF7rG7TBqzkD4K+/SOteky6FO3G4H kowalski@maridia\
\
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA3eq9LLnid5o5Atc53kxreBb5mrq/ecQH4nuD1gAoekUJaYGlzKcqYvBPTD4Fk/l989PdcCQNEhi0ccDJeLzUvBD/5IWidgQay3CcKK4JPqee5Fi1CYLSKsCDWrbs41dg5mExsisCrMUQPr88Ypbyl705E3VFYqfuUxM+ySy/awXmujLK0rjEs+8tyoFh1rveITfN6PEdu9H/2HNPROKsAzgqbiGtjoe+O7MbZgVu7yJLhIJD8DPJkxB5d+3i5+jmbMjz/c/ZnSzCakG4T3iXSN0xgxs4tHU/3JQUzATETmEA39H8GZTH/q3Mn6p4K2zE58apKBGlJDPa91i+yZOyRQ== rsa-key-20171120\
" > /home/rowsdower/.ssh/authorized_keys' - rowsdower
su -c 'chmod 600 /home/rowsdower/.ssh/authorized_keys' - rowsdower

#   INJECT HELPERS
cp ./newnginx.sh /usr/local/bin/newnginx.sh
chmod +x /usr/local/bin/newnginx.sh

#   FAREWELL!
echo "su - rowsdower"
echo "nano ~/.ssh/authorized_keys"
echo "be excellent to each other"
echo "party on dudes"
