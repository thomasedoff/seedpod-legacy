#!/bin/bash

# This script copies default resources within the container to the host machine
# and runs supervisord. Some symlinks are created simply for convenience.

set -e

generateweakhtpasswd() {
  # Generate a plain-text password entry for htpasswd
  PLAIN=$(openssl rand -base64 6)
  echo "seedpod:{PLAIN}${PLAIN}:auto-generated" >> ~/conf/htpasswd
  echo -e " * Generating ruTorrent authentication details ...\n"
  echo -e "   Username: seedpod\n   Password: ${PLAIN}\n" > /proc/self/fd/1
}

generatesslcert() {
  # Generate a self-signed SSL certificate
  echo " * Generating self-signed SSL certificate ..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ~/ssl/cert.key \
    -out ~/ssl/cert.crt \
    -subj "/CN=seedpod.local" 2>/dev/null
}

# Generate necessary directories, files and symlinks for ...
echo " * Making sure are necessary directores and files exist and are writeable ..."
[[ -w ~ ]] || { echo " * Could not write to ${HOME}, check the permissions of the source bind mount directory!"; exit 1; }

# everything
mkdir -p ~/{conf,ssl,.autodl}
mkdir -p ~/rtorrent/{download/{movies,tv,other},log,.session,watch/{movies,tv,other}}
mkdir -p ~/rutorrent/{settings,torrents,users}
mkdir -p ~/.irssi/scripts/{autorun,AutodlIrssi}

# supervisord
[[ -f ~/conf/supervisord.conf ]] || cp /usr/local/etc/supervisord.conf ~/conf/supervisord.conf

# nginx/php-fpm
[[ -f ~/conf/nginx.conf ]] || cp /usr/local/etc/nginx.conf ~/conf/nginx.conf
[[ -f ~/ssl/cert.key && -f ~/ssl/cert.crt ]] || generatesslcert
[[ -f ~/conf/htpasswd ]] || { cp /usr/local/etc/htpasswd ~/conf/htpasswd; generateweakhtpasswd; }
[[ -f ~/conf/php-fpm.conf ]] || cp /usr/local/etc/php-fpm.conf ~/conf/php-fpm.conf

# rtorrent
[[ -f ~/conf/rtorrent.rc ]] || cp /usr/local/etc/rtorrent.rc ~/conf/rtorrent.rc

# rutorrent
[[ -f ~/conf/config.php ]] || cp /usr/local/etc/config.php ~/conf/config.php
[[ -f ~/conf/access.ini ]] || cp /usr/local/etc/access.ini ~/conf/access.ini
[[ -f ~/conf/plugins.ini ]] || cp /usr/local/etc/plugins.ini ~/conf/plugins.ini
[[ -f ~/conf/conf.php ]] || cp /usr/local/etc/conf.php ~/conf/conf.php

# irssi/autodl-irssi
[[ -f ~/.irssi/config ]] || cp /usr/local/etc/config ~/.irssi/config
[[ -S ~/conf/config ]] || ln -sf ./../.irssi/config ~/conf/config
[[ -f ~/.irssi/scripts/AutodlIrssi ]] || cp -R /usr/share/irssi/scripts/AutodlIrssi ~/.irssi/scripts/
[[ -f ~/.irssi/scripts/autorun/autodl-irssi.pl ]] || cp /usr/share/irssi/scripts/autodl-irssi.pl ~/.irssi/scripts/autorun/autodl-irssi.pl
[[ -f ~/.autodl/autodl.cfg ]] || cp /usr/local/etc/autodl.cfg ~/.autodl/autodl.cfg
[[ -S ~/conf/autodl.cfg ]] || ln -sf ./../.autodl/autodl.cfg ~/conf/autodl.cfg

# autodl-rutorrent
[[ -f /home/seedpod/conf/conf.php ]] || cp /usr/local/etc/conf.php ~/conf/conf.php

# run supervisord
echo " * Launching supervisord ..."
supervisord -c /usr/local/etc/supervisord.conf

exit 0
