These scripts are written for and tested on Ubuntu Server 18.04. Currently, the scripts do **NOT** use sudo for privileged commands, instead assuming root.

## How To Use

The `*dependencies.sh` scripts are run once for whichever container you want, server or agent.

The `*launch.sh` and `*removal.sh` scripts can be run as needed, but to launch a new container, the old container must be removed with the removal script. Currently, only one agent can be run per host.

The `*launch.sh` and `*removal.sh` scripts rely on `jenkins.env`, which relies on the user-provided files:

- `jenkins-server.url`
  - Needed by server and agent containers. This file contains the URL that the Jenkins server will be available from.
- `jenkins-agent.secret`
  - Needed by agent container. This file contains a secret generated by the Jenkins server for allowing the agent to connect. It is created by the `Manage Jenkins` > `Manage Nodes` > `New Node` Jenkins admin interface.
- `jenkins-server.plugins`
  - Optionally needed by the server. This file is a list of plugins to automatically be installed on the server.
