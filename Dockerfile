FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  jq \
  git \
  iputils-ping \
  libcurl4 \
  libicu60 \
  libunwind8 \
  netcat \
  libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

# Can be 'linux-x64' or 'linux-arm64'
ARG TARGETARCH
ENV TARGETARCH="${TARGETARCH:-linux-x64}"

# Downloading and installing Powershell for specified targetarch (linux-x64 if build-arg was not used)
RUN curl -L -o /tmp/powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-${TARGETARCH}.tar.gz" \
  && mkdir -p /opt/microsoft/powershell/7 \
  && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
  && chmod +x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pws

# Download and Install Pulumi-CLI
RUN curl -fsSL https://get.pulumi.com | sh

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
