#!/bin/bash

LOG_LEVEL=info /usr/lib/fdo/fdo-manufacturing-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-owner-onboarding-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-serviceinfo-api-server &
LOG_LEVEL=info /usr/lib/fdo/fdo-rendezvous-server &

sleep 3
mkdir /fdoclient
fdo-owner-tool initialize-device 1234 /fdoclient/ownership_voucher /fdoclient/device_credential \
	--device-cert-ca-chain /etc/fdo/keys/device_ca_cert.pem \
	--device-cert-ca-private-key /etc/fdo/keys/device_ca_key.der \
	--manufacturer-cert /etc/fdo/keys/manufacturer_cert.pem \
	--rendezvous-info /etc/fdo/rendezvous-info.yml

export DEVICE_CREDENTIAL=/fdoclient/device_credential

fdo-client-linuxapp
