#!/bin/bash
if [ "$#" -ne "2" ]; then
    echo "Requires 2 parameters [domain, port proxied]"
    exit 2
fi

domain="$1"
port="$2"
conf_path="/etc/nginx/sites-available/${domain}.conf"

# If path already exists, verify you want to redo it
if [ -f "$conf_path" ]; then
    echo "${domain} has already been setup."
    read -p "Do you want to remove its configs and run new anyway? [yn]" answer
    case $answer in
        [yY]* ) rm $conf_path
            ;;
        [nN]* ) echo "have a nice day"
            exit;;
    esac
fi

# add base config to get port 80 wired up
cat - > $conf_path <<TEMPL
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header x-forwarded-for \$remote_addr;
        proxy_cache_bypass \$http_upgrade;
    }

    location /.well-known {
        alias /var/www/$domain/.well-known;
        allow all;
    }
}
TEMPL

nginx -t

if [ "$?" -ne "0" ]; then
    rm $conf_path
    echo "Failed to add ${domain}"
    exit 1
fi

# seems to have added it successfully
ln -s -f $conf_path /etc/nginx/sites-enabled/
systemctl restart nginx
mkdir -p "/var/www/${domain}/.well-known/"
certbot certonly -a webroot --webroot-path=/var/www/$domain -d $domain

if [ "$?" -ne "0" ]; then
    echo "Failed to generate certs. Figure something out"
    exit 1
fi

# certs generated fine, lets build the configs to forward 80->443
cat - > $conf_path <<TEMPL
server {
    listen 80;
    server_name $domain;
    return https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    include snippets/ssl-params.conf;

    location / {
        proxy_pass http://localhost:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /.well-known {
        alias /var/www/$domain/.well-known;
        allow all;
    }
}
TEMPL

nginx -t

if [ "$?" -ne "0" ]; then
    rm $conf_path
    echo "Failed to add ${domain} ssl version"
    exit 1
fi

systemctl restart nginx
echo "Added ${domain} successfully!"

echo ""
