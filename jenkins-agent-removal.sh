#! /usr/bin/env sh

source jenkins.env

set -e
set -v
set -x


docker stop "${JENKINS_AGENT_NAME}"
docker rm "${JENKINS_AGENT_NAME}"