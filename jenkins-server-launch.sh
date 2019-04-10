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
  --expression='s/X-Forwarded-Proto "http"/X-Forwarded-Proto "https"/' \
  --expression='s/X-Forwarded-Port "80"/X-Forwarded-Port "443"/' \
  --in-place \
  "/etc/apache2/sites-available/${JENKINS_SERVER_LE_CONFFILE}"

systemctl reload apache2

set +u

if [ -n "${JENKINS_SERVER_PLUGINS}" ]
then
  docker run \
    --rm \
    --volume="${JENKINS_SERVER_VOLUME}:/var/jenkins_home" \
    'jenkins/jenkins:lts' \
    '/usr/local/bin/install-plugins.sh' \
      ${JENKINS_SERVER_PLUGINS}
fi

set -u

docker run \
  --detach \
  --name='jenkins-server-docker' \
  --restart='unless-stopped' \
  --publish='8080:8080' \
  --publish='50000:50000' \
  --volume="${JENKINS_SERVER_VOLUME}:/var/jenkins_home" \
  'jenkins/jenkins:lts'

set +x

while ! cat "/var/lib/docker/volumes/${JENKINS_SERVER_VOLUME}/_data/secrets/initialAdminPassword" 2>/dev/null
do
  sleep 2s
done
