#!/bin/bash

/usr/lib/fdo/fdo-admin-tool aio --directory /etc/fdo/aio --binary-path /usr/lib/fdo &
LOG_LEVEL=info /usr/lib/fdo/fdo-manufacturing-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-owner-onboarding-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-serviceinfo-api-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-rendezvous-server &

sleep 3

fdo-client-linuxapp
