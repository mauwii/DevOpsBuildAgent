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

# Can be 'x64' or 'arm64'
ARG targetarch
ENV TARGETARCH="linux-${targetarch:-x64}"

# Downloading and installing Powershell for specified targetarch (linux-x64 if build-arg was not used)
RUN curl -L -o /tmp/powershell.tar.gz \
    "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/powershell-7.2.4-${TARGETARCH}.tar.gz" \
  && mkdir -p /opt/microsoft/powershell/7 \
  && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
  && chmod +x /opt/microsoft/powershell/7/pwsh \
  && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# Download and Install Pulumi-CLI
RUN curl -fsSL https://get.pulumi.com | sh \
  && ln -s /root/.pulumi/bin/pulumi /usr/bin/pulumi

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3-pip \
  && python3.8 -m pip install --upgrade pip \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /azp/_work/_tool/Python/3.8.0 \
  && cd /azp/_work/_tool/Python/3.8.0 \
  && python3.8 -m venv x64

# Download and install Azure-CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
