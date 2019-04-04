#! /usr/bin/env sh

source jenkins.env

set -e
set -v
set -x


JENKINS_SERVER_CONF="<VirtualHost *:80>
  ServerName \"${JENKINS_SERVER_URL}\"
  ProxyPass \"/\" \"http://localhost:8080/\" nocanon
  ProxyPassReverse \"/\" \"http://localhost:8080/\"
</VirtualHost>"

echo "${JENKINS_SERVER_CONF}" >"/etc/apache2/sites-available/${JENKINS_SERVER_CONFFILE}"

a2ensite "${JENKINS_SERVER_CONFFILE}"
systemctl reload apache2

certbot \
  --agree-tos \
  --email "admins@cse.ucdavis.edu" \
  run \
    --apache \
    --non-interactive \
    --domain "${JENKINS_SERVER_URL}" \
    --test-cert

docker run \
  --detach \
  --name='jenkins-server-docker' \
  --restart='unless-stopped' \
  -p 8080:8080 \
  -p 50000:50000 \
  -v "${JENKINS_SERVER_VOLUME}:/var/jenkins_home" \
  'jenkins/jenkins:lts'

while ! cat "/var/lib/docker/volumes/${JENKINS_SERVER_VOLUME}/_data/secrets/initialAdminPassword" 2>/dev/null
do
  sleep 2s
done
