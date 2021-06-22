FROM archlinux as builder
RUN pacman -Syyu --noconfirm
RUN pacman -S curl --noconfirm

# Download cockroachdb
WORKDIR /tmp
RUN curl https://binaries.cockroachdb.com/cockroach-v21.1.3.linux-amd64.tgz | tar -xz
RUN cp -i cockroach-v21.1.3.linux-amd64/cockroach /usr/local/bin/

RUN mkdir /cockroach
RUN mkdir /cockroach/certs
RUN mkdir /cockroach/data
RUN mkdir /cockroach/executable

ENTRYPOINT cockroach start --certs-dir=/cockroach/certs --store=/cockroach/data --listen-addr=localhost:26257 --http-addr=localhost:8080 --background --join=$JOINADDR