# seedpod Dockerfile

# docker build --rm -t seedpod .
# mkdir /home/thomas/seedpod-data
# docker run -it --rm -p8000:8000 -p50000:50000 --mount type=bind,source=/home/thomas/seedpod-data,target=/home/seedpod seedpod

FROM debian:testing-slim
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
  supervisor \
  nginx \
  libnginx-mod-stream \
  php-fpm \
  php-xml \
  php-geoip \
  geoip-database \
  rtorrent \
  unzip \
  unrar-free \
  procps \
  ca-certificates \
  curl \
  irssi \
  libxml-libxml-perl \
  libjson-perl \
  libarchive-zip-perl \
  libhtml-parser-perl \
  libnet-ssleay-perl \
  screen && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m -G tty seedpod

# supervisord
COPY --chown=seedpod:seedpod conf-default/supervisord.conf /usr/local/etc/supervisord.conf

# rtorrent
COPY --chown=seedpod:seedpod conf-default/rtorrent.rc /usr/local/etc/rtorrent.rc

# nginx/php-fpm
COPY --chown=seedpod:seedpod conf-default/nginx.conf conf-default/htpasswd conf-default/php-fpm.conf /usr/local/etc/
RUN chown -R seedpod:seedpod /var/log/nginx

# rutorrent
RUN mkdir /var/www/html/rutorrent && \
  curl -sL https://github.com/Novik/ruTorrent/archive/v3.10-beta.tar.gz | \
  tar xz --strip=1 -C /var/www/html/rutorrent/ && \
  ln -sf /home/seedpod/conf/config.php /var/www/html/rutorrent/conf/config.php && \
  ln -sf /home/seedpod/conf/access.ini /var/www/html/rutorrent/conf/access.ini && \
  ln -sf /home/seedpod/conf/plugins.ini /var/www/html/rutorrent/conf/plugins.ini
COPY --chown=seedpod:seedpod conf-default/config.php conf-default/access.ini conf-default/plugins.ini /usr/local/etc/

# irssi/autodl-irssi
RUN curl -sL https://github.com/autodl-community/autodl-irssi/archive/2.6.2.tar.gz | \
  tar xz --strip=1 -C /usr/share/irssi/scripts/ \
    autodl-irssi-2.6.2/AutodlIrssi \
    autodl-irssi-2.6.2/autodl-irssi.pl
COPY --chown=seedpod:seedpod conf-default/config conf-default/startup conf-default/autodl.cfg /usr/local/etc/

# autodl-rutorrent
RUN mkdir /var/www/html/rutorrent/plugins/autodl-irssi && \
  curl -sL https://github.com/autodl-community/autodl-rutorrent/archive/v2.3.0.tar.gz | \
  tar xz --strip=1 -C /var/www/html/rutorrent/plugins/autodl-irssi/ && \
  ln -sf /home/seedpod/conf/conf.php /var/www/html/rutorrent/plugins/autodl-irssi/conf.php
COPY --chown=seedpod:seedpod conf-default/conf.php /usr/local/etc/

# init.sh
COPY --chown=seedpod:seedpod init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

USER seedpod
ENTRYPOINT ["/usr/local/bin/init.sh"]
