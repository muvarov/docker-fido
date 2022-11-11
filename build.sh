#!/bin/bash

set -evx

sudo docker build .
ID=`sudo docker images --format="{{.ID}}" | head -1`

mkdir -p client/etc

sudo docker run -i -v `pwd`/client:/client ${ID} << EOF
	cp /fdoclient/device_credential /client/etc/
EOF
