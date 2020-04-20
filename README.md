# seedpod
[seedpod](https://github.com/thomasedoff/seedpod) "Dockerizes" rTorrent, ruTorrent, Irssi, autodl-irssi and autodl-rutorrent to provide the typical functionality of a seedbox.

![seedpod](https://user-images.githubusercontent.com/51061686/79761299-85ca2b80-8321-11ea-97cb-90d735583b74.png)

## Introduction
I needed a "seedbox-like" setup for a private project but as the setup grew I decided to migrate everyting to it's own repository and make it public. My ambition is to keep it as minimal and functional as possible.

Some notable differences to similar projects (for better or worse) may be:
 - Minimal bloat and ready-to-go default configuration
 - Configuration files are stored on the host machine 
 - All processes within the container are unprivileged
-  HTTP and HTTPS are supported on the same TCP port
 - HTTP/2 and Basic Authentication are enabled by default
 - Use of UNIX sockets rather than TCP (and thus no need to expose /RPC2)
 - Debian (testing) repository used as much as possible, no patching or compilation required

## Instructions
Clone Github repository:
```bash
git clone https://github.com/thomasedoff/seedpod.git ~/seedpod.git
```

Build Docker image from Dockerfile:
```bash
cd ~/seedpod.git
docker build --rm -t seedpod .
```` 

Create source bind mount directory (this is where all configuration and your data will be stored):
```bash
mkdir ~/seedpod-data
```

Run Docker container (with example bind mount source path, Nginx- and rTorrent host machine ports):
```bash
docker run -it --rm \
  -p8000:8000 -p50000:50000 \
  --mount type=bind,source=${HOME}/seedpod-data,target=/home/seedpod \
  seedpod
```

A pseudo-random password will be generated and output to the terminal. Use it to authenticate to ruTorrent. Finally, visit ruTorrent (on whatever TCP port you exposed for Nginx on the host machine). 

For example: **https://localhost:8000/rutorrent/**

## Configuration
By default, Nginx/ruTorrent binds to **8000/tcp** and rTorrent to **50000/tcp** within the container. All other settings - with a few exceptions (see below) - should be according to default templates and project recommendations.

On the first run, all configuration files will be copied from the container to the host machine via the shared bind mount. In order to change (any) configuration, simply edit the files that were created in `seedpod-data/conf` and restart the container. The SSL certificate and RSA key used by Nginx can be found in `seedpod-data/ssl`. Existing/changed files on the host machine will NOT be overwritten by the container.

### Configuration file overview
Overview of the configuration files:
| File             | Description |
|------------------|-------------|
| supervisord.conf | [Supervisord]( http://supervisord.org/configuration.html) |
| nginx.conf       | [Nginx main](https://nginx.org/en/docs/) |
| htpasswd         | [Nginx authentication](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/) |
| php-fpm.conf     | [PHP-FPM](https://www.php.net/manual/en/install.fpm.configuration.php) |
| rtorrent.rc      | [rTorrent main](https://rtorrent-docs.readthedocs.io/en/latest) |
| config.php       | [ruTorrent main](https://github.com/Novik/ruTorrent/wiki/Config#configphp) |
| access.ini       | [ruTorrent user access](https://github.com/Novik/ruTorrent/wiki/Config#accessini) |
| plugins.ini      | [ruTorrent plugin control](https://github.com/Novik/ruTorrent/wiki/Config#pluginsini) |
| autodl.cfg       | [autodl-irssi](https://autodl-community.github.io/autodl-irssi/configuration/options/) |
| config           | [Irssi](https://irssi.org/documentation/settings/) |
| conf.php         | [autodl-rutorrent]( https://github.com/autodl-community/autodl-rutorrent/wiki) |

### Some noteable configurations to (re)consider
I prefer keeping configuration secure-*ish* by default. Here's some settings you might want to have a look at:
 - List of enabled ruTorrent plugins in `plugins.ini`
 - `forbidUserSettings` and `profileMask` in `config.php`
 - `auth_basic` and `auth_basic_user_file` in `nginx.conf`, as well as `conf/htpasswd`
 - `protocol.encryption.set` and `system.umask.set` in `rtorrent.rc`

## Software stack
 - [Debian](https://www.debian.org/) (Testing)
 - [Supervisord](http://supervisord.org/)
 - [Nginx](https://www.nginx.com/)
 - [PHP-FPM](https://www.php.net/)
 - [rTorrent](https://rakshasa.github.io/rtorrent/)
 - [ruTorrent](https://github.com/Novik/ruTorrent)
 - [Irssi](https://irssi.org/)
 - [autodl-irssi](https://github.com/autodl-community/autodl-irssi)
 - [autodl-rutorrent](https://github.com/autodl-community/autodl-rutorrent)
 - Some tools (like curl, screen, etc) and a single shell script.

## Future plans
 - Make sure everything actually works! :)
 - prerequisite section?
 - Generate htpasswd-oneliner in README?
 - Dockerfile LABEL? HEALTHCHECK?
 - Docker restart-policy?
 - useradd -u, Docker USER and --user?
 - VPN/Wireguard?
 - Other self-hosted options (Ansible, .vdi)?
