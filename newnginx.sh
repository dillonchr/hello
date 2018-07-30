#!/bin/bash
if [ "$#" -eq "3" ]; then
    type="$1"
    domain="$2"
    options="$3"

    if [ "$type" -eq "1" ]; then
    
    template="
server {
  listen 80;
  server_name $domain;

  location / {
    proxy_pass http://localhost:$options;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }

  location /.well-known {
    alias /var/www/$domain/.well-known;
    allow all;
  }
}
"

    else
        # static
    template="
server {
  listen 80;

  server_name $domain;

  root $options;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ /.well-known {
    allow all;
  }
}
"

    fi

    conf_path="/etc/nginx/sites-available/${domain}.conf"
    echo $template > $conf_path
    ln -s $conf_path /etc/nginx/sites-enabled/
    systemctl restart nginx
    echo "Added ${domain}"

else
    echo "Requires 3 parameters [type (1 proxy, 2 static), domain, if type=1 ? port proxied : path/to/static/files]"
fi

echo ""

