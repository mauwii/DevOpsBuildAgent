ARG platformos='linux'
ARG platformarch='amd64'
FROM --platform="${platformos}/${platformarch}" ubuntu:20.04

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ARG targetos='linux'
ARG targetproc='x64'
ENV TARGETARCH="${targetos}-${targetproc}"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
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

# Install Azure-CLI
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3.8-dev \
    python3-pip \
    gcc \
  && pip install --upgrade pip setuptools wheel azure-cli

# Downloading and installing Powershell for specified targetproc (linux-x64 if build-arg was not used)
RUN curl -L -o /tmp/powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-${TARGETARCH}.tar.gz" \
  && mkdir -p /opt/microsoft/powershell/7 \
  && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
  && chmod +x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Create Python3.8.10 tool directory, upgrade pip, install setuptools and wheel
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    python3.8-dev \
    python3.8-venv \
    gcc \
  && mkdir -p /azp/_work/_tool/Python/3.8.10 \
  && cd /azp/_work/_tool/Python/3.8.10 \
  && python3.8 -m venv x64 \
  && touch x64.complete \
  && . /azp/_work/_tool/Python/3.8.10/x64/bin/activate \
  && pip install --upgrade pip setuptools wheel psutil

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "/usr/bin/env", "bash", "./start.sh" ]
