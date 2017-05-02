#!/usr/bin/env bash

echo "stopping buddy to be sure"
echo "make sure buddy now serves on default ports"

docker-compose stop
sudo buddy stop

if patch --dry-run --reverse --force ~/.buddy/docker-compose.tmpl diff/buddy-compose.patch >/dev/null 2>&1; then
    echo "patch already applied (or failed who knows)"
else
    patch ~/.buddy/docker-compose.tmpl diff/buddy-compose.patch
fi

sudo buddy start | while read LOGLINE
do
   echo "${LOGLINE}"
   [[ "${LOGLINE}" == *"buddy_proxy_server"* ]] && killall buddy
done

echo "Starting Traefik proxy"

docker-compose up -d

echo "all containers should be launched correctly, just wait until buddy comes online"

