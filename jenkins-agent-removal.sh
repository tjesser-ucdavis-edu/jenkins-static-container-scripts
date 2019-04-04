#! /usr/bin/env sh

. ./jenkins.env

set -u
set -v
set -x


docker stop "${JENKINS_AGENT_NAME}"
docker rm "${JENKINS_AGENT_NAME}"
