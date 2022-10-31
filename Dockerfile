FROM arm64v8/debian:sid-20221004

RUN apt-get update && \
	apt install --no-install-recommends -y git \
	rust-all \
	ca-certificates \
	cryptsetup \
	libcryptsetup-dev \
	pkg-config \
	libtss2-dev libtss2-tcti-tabrmd-dev libtss2-mu0 libtss2-rc0 tss2 \
	tpm2-openssl librust-openssl-dev librust-clang-sys-dev golang-go 

RUN git clone https://github.com/fedora-iot/fido-device-onboard-rs.git

RUN cd fido-device-onboard-rs && cargo build --release
RUN cd fido-device-onboard-rs && cargo install all
ENV PATH="/root/.cargo/bin:$PATH"

RUN cd fido-device-onboard-rs && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-client-linuxapp && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-manufacturing-client && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-manufacturing-server && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-owner-onboarding-server && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-rendezvous-server && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-serviceinfo-api-server && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-owner-tool && \
install -D -m 0755 -t /usr/lib/fdo target/release/fdo-admin-tool && \
install -D -m 0755 -t /bin target/release/fdo-owner-tool && \
install -D -m 0755 -t /bin target/release/fdo-admin-tool && \
install -D -m 0644 -t /lib/systemd/system examples/systemd/* && \
install -D -m 0644 -t /usr/share/doc/fdo examples/config/* && \
mkdir -p /etc/fdo && \
install -D -m 0755 -t /usr/lib/dracut//modules.d/52fdo dracut/52fdo/module-setup.sh && \
install -D -m 0755 -t /usr/lib/dracut/modules.d/52fdo dracut/52fdo/manufacturing-client-generator && \
install -D -m 0755 -t /usr/lib/dracut/modules.d/52fdo dracut/52fdo/manufacturing-client-service && \
install -D -m 0755 -t /usr/lib/dracut/modules.d/52fdo dracut/52fdo/manufacturing-client.service

# Configure stage from https://www.redhat.com/sysadmin/edge-device-onboarding-fdo
# Configure the Manufacturing server
RUN mkdir /etc/fdo/keys && \
	for i in manufacturer owner device-ca diun ; do fdo-admin-tool generate-key-and-cert --destination-dir /etc/fdo/keys $i; done && \
	ls /etc/fdo/keys
RUN mkdir -p /etc/fdo/stores/manufacturer_keys && \
    mkdir -p /etc/fdo/stores/manufacturing_sessions && \
    mkdir -p /etc/fdo/stores/owner_vouchers
COPY manufacturing-server.yml /etc/fdo/
# then run /usr/lib/fdo/fdo-manufacturing-server

# Configure the Rendezvous server
RUN mkdir -p /etc/fdo/stores/rendezvous_registered && \
    mkdir -p /etc/fdo/stores/rendezvous_sessions

COPY rendezvous-server.yml /etc/fdo/
# then run: LOG_LEVEL=info /usr/lib/fdo/fdo-rendezvous-server
CMD LOG_LEVEL=info /usr/lib/fdo/fdo-rendezvous-server &

# Configure the Owner server
RUN mkdir -p /etc/fdo/stores/owner_vouchers && \
    mkdir -p /etc/fdo/stores/owner_onboarding_sessions
COPY owner-onboarding-server.yml /etc/fdo
# then run: LOG_LEVEL=info /usr/lib/fdo/fdo-owner-onboarding-server
COPY serviceinfo-api-server.yml /etc/fdo

RUN apt install --no-install-recommends -y procps 
# then run: LOG_LEVEL=info /usr/lib/fdo/fdo-serviceinfo-api-server

COPY rendezvous-info.yml /etc/fdo 
ENV DEVICE_CREDENCIAL="/credential"

COPY fido_run.sh /bin/
RUN chmod +x /bin/fido_run.sh

CMD /bin/fido_run.sh

ENV PATH="/usr/lib/fdo/:$PATH"
# ENTRYPOINT [ "/bin/sh" ]
# use /usr/lib/fdo/fdo-client-linuxapp client 
