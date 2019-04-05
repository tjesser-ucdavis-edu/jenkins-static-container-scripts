#! /usr/bin/env sh

. ./jenkins.env

set -u
set -v
set -x


a2dissite "${JENKINS_SERVER_CONFFILE}"
a2dissite "${JENKINS_SERVER_LE_CONFFILE}"
systemctl reload apache2

rm "/etc/apache2/sites-available/${JENKINS_SERVER_CONFFILE}"
rm "/etc/apache2/sites-available/${JENKINS_SERVER_LE_CONFFILE}"

certbot delete \
  --cert-name "${JENKINS_SERVER_URL}"

docker stop "${JENKINS_SERVER_NAME}"
docker rm "${JENKINS_SERVER_NAME}"

docker volume rm "${JENKINS_SERVER_VOLUME}"
