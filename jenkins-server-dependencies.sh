#! /usr/bin/env sh

set -e
set -u
set -v
set -x


apt update
apt upgrade --yes
apt autoremove --yes

apt install --yes \
  apache2 \
  docker.io \
  software-properties-common

add-apt-repository --yes universe
add-apt-repository --yes ppa:certbot/certbot

apt update
apt upgrade --yes
apt autoremove --yes

apt install --yes \
  certbot \
  python-certbot-apache

systemctl enable apache2
systemctl enable docker

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_wstunnel

a2dissite 000-default.conf

systemctl restart apache2
