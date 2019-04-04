#! /usr/bin/env sh

source jenkins.env

set -e
set -v
set -x


a2dissite "${JENKINS_SERVER_CONFFILE}"

rm "/etc/apache2/sites-available/${JENKINS_SERVER_CONFFILE}"

certbot delete \
  --cert-name "${JENKINS_SERVER_URL}"

docker stop "${JENKINS_SERVER_NAME}"
docker rm "${JENKINS_SERVER_NAME}"

docker volume rm "${JENKINS_SERVER_VOLUME}"
