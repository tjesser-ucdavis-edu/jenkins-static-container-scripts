#! /usr/bin/env sh

. ./jenkins-server.env

set -u
set -v
set -x


a2dissite "${JENKINS_SERVER_CONFFILE}"
a2dissite "$(basename ${JENKINS_SERVER_CONFFILE} .conf)-le-ssl.conf"
systemctl reload apache2

rm "/etc/apache2/sites-available/${JENKINS_SERVER_CONFFILE}"
rm "/etc/apache2/sites-available/$(basename ${JENKINS_SERVER_CONFFILE} .conf)-le-ssl.conf"

certbot delete \
  --cert-name "${JENKINS_SERVER_URL}"

docker stop "${JENKINS_SERVER_NAME}"
docker rm "${JENKINS_SERVER_NAME}"

docker volume rm "${JENKINS_SERVER_VOLUME}"
