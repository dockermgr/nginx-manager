#!/usr/bin/env bash

mkdir -p /srv/docker/nginx-manager/{config,data,letsencrypt} && chmod -Rf 777 /srv/docker/nginx-manager

cat <<EOF | sudo tee > /srv/docker/nginx-manager/config/config.json
{
  "database": {
    "engine": "knex-native",
    "knex": {
      "client": "sqlite3",
      "connection": {
        "filename": "/data/database.sqlite"
      }
    }
  }
}
EOF

docker run -d \
--name=nginx-manager \
--hostname nginx-manager \
--restart=always \
--privileged \
-e DISABLE_IPV6=true \
-p 80:80 \
-p 443:443 \
-p 81:81 \
-v /srv/docker/nginx-manager/data:/data \
-v /srv/docker/nginx-manager/letsencrypt:/etc/letsencrypt \
-v /srv/docker/nginx-manager/config/config.json:/app/config/production.json \
jc21/nginx-proxy-manager:2
