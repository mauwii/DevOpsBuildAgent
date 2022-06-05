# ARG targetplatform="linux/amd64"
# FROM --platform="${targetplatform}" ubuntu:20.04
FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  git \
  iputils-ping \
  jq \
  lsb-release \
  software-properties-common

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ARG targetarch="linux-x64"
ENV TARGETARCH="${targetarch}"

# Downloading and installing Powershell for specified targetarch (linux-x64 if build-arg was not used)
RUN curl -L -o /tmp/powershell.tar.gz \
  "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-${TARGETARCH}.tar.gz" \
  && mkdir -p /opt/microsoft/powershell/7 \
  && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
  && chmod +x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Create Python3.8.10 tool directory
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
  python3.8-venv \
  && mkdir -p /azp/_work/_tool/Python/3.8.10 \
  && cd /azp/_work/_tool/Python/3.8.10 \
  && python3.8 -m venv x64 \
  && touch x64.complete

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
