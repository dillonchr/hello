#!/bin/bash
if [ "$#" -eq "3" ]; then
type="$1"
domain="$2"
options="$3"
conf_path="/etc/nginx/sites-available/${domain}.conf"

if [ -f "$conf_path" ]; then
    echo "${domain} has already been setup."
    read -p "Do you want to remove its configs and run new anyway? [yn]" answer
    case $answer in
        [yY]* ) rm $conf_path
            break;;
        [nN]* ) echo "have a nice day"
            exit;;
    esac
fi

if [ "$type" -eq "1" ]; then

    cat - > $conf_path <<TEMPL
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:$options;
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


else
# static
    cat - > $conf_path <<TEMPL
server {
    listen 80;
    server_name $domain;

    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl $domain;
    listen [::]:443 ssl $domain;
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    include snippets/ssl-params.conf;
    server_name $domain;
    

    location / {
        proxy_pass http://localhost:$options;
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

fi

nginx -t

if [ "$?" -ne "0" ]; then
    rm $conf_path
    echo "Failed to add ${domain}"
else
    ln -s $conf_path /etc/nginx/sites-enabled/
    systemctl restart nginx
    echo "Added ${domain}"
fi

else
    echo "Requires 3 parameters [type (1 proxy, 2 static), domain, if type=1 ? port proxied : path/to/static/files]"
fi

echo ""

