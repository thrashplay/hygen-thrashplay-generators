#!/usr/bin/env sh

curl -i -X POST https://drone.thrashplay.com/api/repos/thrashplay/thrashplay-app-creators/builds -H "Authorization: Bearer ${DRONE_TOKEN}"
