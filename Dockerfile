# syntax=docker/dockerfile:1
FROM --platform=${TARGETPLATFORM} ubuntu:20.04

# Prepare apt for buildkit cache
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache

# Prepare pip for buildkit cache
ARG PIP_CACHE_DIR=/var/cache/buildkit/pip
ENV PIP_CACHE_DIR ${PIP_CACHE_DIR}
RUN mkdir -p ${PIP_CACHE_DIR}

ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' >/etc/apt/apt.conf.d/90assumeyes

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ARG targetos=linux
ARG targetproc=x64

RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    unzip \
    zip

# Install Azure-CLI v2.37.0
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=${PIP_CACHE_DIR} \
  apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    gnupg \
    python3-dev \
    python3-pip \
    gcc \
  && pip3 install \
    --upgrade \
    --force \
    pip \
  && pip3 install \
    --upgrade \
    --force \
    azure-cli==2.37.0 \
  && apt-get remove -y \
    python3-pip \
  && apt-get autoremove -y

# Downloading and installing Powershell for specified TARGETARCH (linux-x64 per default)
RUN curl -L -o /tmp/powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-${targetos}-${targetproc}.tar.gz" \
  && mkdir -p /opt/microsoft/powershell/7 \
  && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
  && chmod +x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Install Azure Powershell Module v8.0.0
RUN /usr/bin/pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted \
  && /usr/bin/pwsh -Command Install-Module -Name Az -RequiredVersion 8.0.0 -Scope AllUsers

# Setup Runtime
ENV TARGETARCH ${targetos}-${targetproc}
WORKDIR /azp
COPY ./start.sh .
RUN chmod +x start.sh
ENTRYPOINT [ "start.sh" ]
