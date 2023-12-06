# syntax=docker/dockerfile:1.4
ARG IMAGE_LANG=alpine
ARG IMAGE_VERSION=3.18

FROM ${IMAGE_LANG}:${IMAGE_VERSION}

LABEL maintainer="Mike Glenn <mglenn@ilude.com>"

ARG PUID=1000
ARG PGID=1000

ARG USER
ARG PROJECT_NAME
ARG HOST_PROJECT_PATH
ARG TZ
ENV USER=${USER}
ENV PROJECT_NAME=${PROJECT_NAME}
ENV HOST_PROJECT_PATH=${HOST_PROJECT_PATH}
ENV TZ=${TZ}

RUN apk add --no-cache \
		bash \
		binutils \
		curl \
		git \
		make \
		openssh-client \
		py3-pip \
		sudo \
		tzdata \
		zsh \
		zsh-autosuggestions && \
    rm -rf /var/lib/apt/lists/* 

RUN addgroup -g ${PGID} ${USER} && \
		adduser -u ${PUID} -G ${USER} -s /bin/zsh -D ${USER} && \
    echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    mkdir -p /workspace/${PROJECT_NAME} && \
		ln -s /usr/share/zoneinfo/${TZ} /etc/localtime

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