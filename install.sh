#!/usr/bin/env bash

APPNAME="nginx-manager"
DATADIR="/srv/docker/$APPNAME"

mkdir -p "$DATADIR"/{config,data,letsencrypt} && chmod -Rf 777 "$DATADIR"

if docker ps -a | grep "$APPNAME" >/dev/null 2>&1; then
docker stop "$APPNAME"
docker rm -f "$APPNAME"
docker pull jc21/nginx-proxy-manager:2
fi

if [ ! -f "/srv/docker/nginx-manager/config/config.json" ]; then
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
fi

docker run -d \
--name="$APPNAME" \
--hostname "$APPNAME" \
--restart=always \
--privileged \
-e DISABLE_IPV6=true \
-p 80:80 \
-p 443:443 \
-p 81:81 \
-v $DATADIR/data:/data \
-v $DATADIR/letsencrypt:/etc/letsencrypt \
-v $DATADIR/config/config.json:/app/config/production.json \
jc21/nginx-proxy-manager:2
