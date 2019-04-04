#! /usr/bin/env sh

set -e
set -u
set -v
set -x


apt update
apt upgrade --yes
apt autoremove --yes

apt install --yes \
  docker.io

systemctl enable docker
