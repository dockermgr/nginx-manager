# Welcome to dockermgr nginx-manager installer 👋

## To install

```shell
dockermgr install nginx-manager
```  


```shell
sudo docker run -d \
    --name="nginx-manager" \
    --hostname "$HOSTNAME" \
    --restart=unless-stopped \
    --privileged \
    -e TZ="America/New_York" \
    -e DISABLE_IPV6=true \
    -v "$HOME/.local/share/srv/docker/nginx-manager/files/data":/data \
    -v "$HOME/.local/share/srv/docker/nginx-manager/files/config/production.json":/app/config/production.json \
    -v "$HOME/.local/share/srv/docker/nginx-manager/files/letsencrypt":/etc/letsencrypt \
    -p 80:80 \
    -p 8888:81 \
    -p 443:443 \
    jc21/nginx-proxy-manager:2 1>/dev/null
```

## Author  

👤 **Jason Hempstead**  
