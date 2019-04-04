#! /usr/bin/env sh

. ./jenkins.env

set -e
set -u
set -v
set -x


JENKINS_SERVER_CONF="<VirtualHost *:80>
  ServerName \"${JENKINS_SERVER_URL}\"

  ProxyPass \"/\" \"http://localhost:8080/\" nocanon
  ProxyPassReverse \"/\" \"http://localhost:8080/\"

  AllowEncodedSlashes NoDecode

  RequestHeader set X-Forwarded-Proto \"http\"
  RequestHeader set X-Forwarded-Port \"80\"
</VirtualHost>"

echo "${JENKINS_SERVER_CONF}" >"/etc/apache2/sites-available/${JENKINS_SERVER_CONFFILE}"

a2ensite "${JENKINS_SERVER_CONFFILE}"
systemctl reload apache2

certbot \
  --agree-tos \
  --email "admins@cse.ucdavis.edu" \
  run \
    --apache \
    --hsts \
    --non-interactive \
    --redirect \
    --domain "${JENKINS_SERVER_URL}"

sed \
  -e 's/X-Forwarded-Proto "http"/X-Forwarded-Proto "https"/' \
  -e 's/X-Forwarded-Port "80"/X-Forwarded-Port "443"/' \
  --in-place \
  "/etc/apache2/sites-available/$(basename ${JENKINS_SERVER_CONFFILE} .conf)-le-ssl.conf"

systemctl reload apache2

docker run \
  --detach \
  --name='jenkins-server-docker' \
  --restart='unless-stopped' \
  -p 8080:8080 \
  -p 50000:50000 \
  -v "${JENKINS_SERVER_VOLUME}:/var/jenkins_home" \
  'jenkins/jenkins:lts'

set +x

while ! cat "/var/lib/docker/volumes/${JENKINS_SERVER_VOLUME}/_data/secrets/initialAdminPassword" 2>/dev/null
do
  sleep 2s
done
