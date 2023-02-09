# Container image that runs your code
FROM alpine:3.17

RUN apk add --no-cache git jq curl

# Use icecon instead. For some reason rcon-cli doesn't send a valid command
#ARG RCON_VERSION="0.10.2"
#
#RUN curl -LO https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz && \
#    tar -xvf rcon-${RCON_VERSION}-amd64_linux.tar.gz && \
#    mv rcon-${RCON_VERSION}-amd64_linux/rcon /usr/local/bin/ && \
#    rm -rf rcon-${RCON_VERSION}-amd64_linux*

ARG ICECON_VERSION="v1.0.0"

RUN wget https://github.com/icedream/icecon/releases/download/${ICECON_VERSION}/icecon_linux_i386 && \
    mv icecon_linux_i386 /usr/local/bin/icecon && \
    chmod +x /usr/local/bin/icecon

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
