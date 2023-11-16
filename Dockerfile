# syntax=docker/dockerfile:1.4 
FROM ruby:3.2-bookworm

ARG PUID=1000
ARG PGID=1000
ARG USER=anvil
ENV USER=${USER}

ARG PROJECT_NAME=app
ENV PROJECT_NAME=${PROJECT_NAME}

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    git-doc \
    freetds-dev \
    make \
    symlinks \
    tldr \
    tree \
    nano \
    openssl \
    openssh-client \
    python3 \
    rsync \
    sshpass \
    sudo \
    tzdata \
    zsh \
    zsh-autosuggestions && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/UID_MAX .*/UID_MAX    100000/' /etc/login.defs && \
    groupadd --gid ${PGID} ${USER} && \
    useradd --uid ${PUID} --gid ${PGID} -s /bin/zsh -m ${USER} && \
    echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    mkdir -p /workspace/${PROJECT_NAME}

#     useradd -M -s /bin/false -u 65532 cloudflare && \



COPY --chmod=755 <<-"EOF" /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
set -e
if [ -v DOCKER_ENTRYPOINT_DEBUG ] && [ "$DOCKER_ENTRYPOINT_DEBUG" == 1 ]; then
  set -x
  set -o xtrace
fi

echo "Running: $@"
exec $@
EOF

ENV HOME=/home/${USER}
USER ${USER}



# https://code.visualstudio.com/remote/advancedcontainers/start-processes#_adding-startup-commands-to-the-docker-image-instead
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "sleep", "infinity" ]