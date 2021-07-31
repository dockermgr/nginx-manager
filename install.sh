#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="nginx-manager"
VERSION="202107311147-git"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"
SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 202107311147-git
# @Author        : casjay
# @Contact       : casjay
# @License       : WTFPL
# @ReadME        : dockermgr --help
# @Copyright     : Copyright: (c) 2021 casjay, casjay
# @Created       : Saturday, Jul 31, 2021 11:47 EDT
# @File          : nginx-manager
# @Description   : nginx-manager docker container installer
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-testing.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/$GIT_DEFAULT_BRANCH/functions}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# user system devenv dfmgr dockermgr fontmgr iconmgr pkmgr systemmgr thememgr wallpapermgr
dockermgr_install
__options "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Begin installer
APPNAME="nginx-manager"
DOCKER_HUB_URL="jc21/nginx-proxy-manager:2"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPDIR="${APPDIR:-/usr/local/share/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME}"
INSTDIR="${INSTDIR:-/usr/local/share/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME}"
DATADIR="${DATADIR:-/srv/docker/$APPNAME}"
REPORAW="$REPO/raw/$GIT_DEFAULT_BRANCH"
APPVERSION="$(__appversion "$REPORAW/version.txt")"
TIMEZONE="${TZ:-$TIMEZONE}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sudo mkdir -p "$DATADIR"/{config,data,letsencrypt}
sudo chmod -Rf 777 "$DATADIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ ! -f "$DATADIR/config/config.json" ]; then
  cat <<EOF | sudo tee $DATADIR/config/config.json >/dev/null 2>&1
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
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$INSTDIR/docker-compose.yml" ]; then
  printf_blue "Installing containers using docker compose"
  sed -i "s|REPLACE_DATADIR|$DATADIR" "$INSTDIR/docker-compose.yml"
  if cd "$INSTDIR"; then
    sudo docker-compose pull &>/dev/null
    sudo docker-compose up -d &>/dev/null
  fi
else
  if docker ps -a | grep -qs "$APPNAME"; then
    sudo docker rm "$APPNAME" -f &>/dev/null
    sudo docker pull "$DOCKER_HUB_URL" &>/dev/null
    sudo docker restart "$APPNAME" &>/dev/null
  else
    sudo docker run -d \
      --name="$APPNAME" \
      --hostname "$APPNAME" \
      --restart=unless-stopped \
      --privileged \
      -e TZ=${TIMEZONE:-America/New_York} \
      -v "$DATADIR/data":/data:z \
      -v "$DATADIR/letsencrypt":/etc/letsencrypt:z \
      -v $"$DATADIR/config/config.json":/app/config/production.json:z \
      -e DISABLE_IPV6=true \
      -p 80:80 \
      -p 443:443 \
      -p 8888:81 \
    "$DOCKER_HUB_URL" &>/dev/null
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if docker ps -a | grep -qs "$APPNAME"; then
  printf_green "Successfully setup nginx-manager"
  printf_blue "Email:      admin@example.com"
  printf_blue "Password:   changeme"
else
  printf_return "Could not setup nginx-manager"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End script
exit $?
