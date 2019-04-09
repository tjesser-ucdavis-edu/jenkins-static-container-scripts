#! /usr/bin/env sh

. ./jenkins.env

set -e
set -u
set -v
set -x


docker run \
  --detach \
  --group-add="$(getent group docker | awk -F ':' '{print $3}')" \
  --name="${JENKINS_AGENT_NAME}" \
  --restart='unless-stopped' \
  --volume='/var/run/docker.sock:/var/run/docker.sock' \
  'jenkins/jnlp-agent-docker:latest' \
    -url "https://${JENKINS_SERVER_URL}" \
    "${JENKINS_AGENT_SECRET}" \
    "$(hostname)"
