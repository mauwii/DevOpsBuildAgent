# DevOpsBuildAgent

# NEWS FLASH: Updated to Ubuntu 20.04

## What's new

Well, besides the 4 Year release-date difference (yes, 18.04 is LTS, but still ... :trollface:) there has been much going on. For Example we are not bound to some very outdated Python Versions anymore, since the shipped Version of Python is already 3.8.10 (vs 3.6.9), which I obviously enabled again to be compatible with the usePythonVersion Task.

First Thing I will now try to sort out is the problem which is blocking us from using a ARM64 Base Image, which looks to me like it is caused by the Version of Azure-CLI, which should be fixable since my Macbook tells me it is using a arm64 Version:

``` sh
 ~  cat $(which az)
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /opt/homebrew/bin/az
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env bash
   2   │ AZ_INSTALLER=HOMEBREW /opt/homebrew/Cellar/azure-cli/2.37.0/libexec/bin/python -m azure.cli "$@"
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 ~  file /opt/homebrew/Cellar/azure-cli/2.37.0/libexec/bin/python
/opt/homebrew/Cellar/azure-cli/2.37.0/libexec/bin/python: Mach-O 64-bit executable arm64
```

So I will not waste any more time to write some incomplete changelogs or anything and directly jump back to action while you cross your fingers that it will work out :godmode: Meanwhile my Apple Silicon Friends should be fine by using the x64 image (f.e. by running the container with `run-local.sh x64`)

## buildx

There is a new experimental Feature in Docker to build Multiarch Containers, it could be used like:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64/v8 \
  -t mauwii/devopsbuildagent:latest \
  --push .
```

But since Azure-DevOps is not supporting it yet, this is currently no option for me.

## azure-cli in arm64

Since the Installation Script (`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`) unfortunatelly does not support arm64 architecture, I tried to install it manually.

My first attempt was to create a Stage in the Dockerfile out of the [manual installation steps](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-2-step-by-step-installation-instructions), which did not work out at all. If you are curious, it looked like this:

```Docker
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends apt-get install ca-certificates curl apt-transport-https lsb-release gnupg \
  && curl -sL https://packages.microsoft.com/keys/microsoft.asc| gpg --dearmor| tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
  && AZ_REPO=$(lsb_release -cs) \
  && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main"| tee /etc/apt/sources.list.d/azure-cli.list \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends apt-get install azure-cli
```

After experimenting a bit, I came to a solution where I just installed azure-cli via pip, which I tested yet to be working in x64 as well as arm64:

```Docker
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
```

---

What follows is the original Readme :neckbeard:

## What

This is a Dockerimage to create and run a Linux based Agent for Azure-DevOps which initially got created as described [here](https://docs.microsoft.com/azure/devops/pipelines/agents/docker?view=azure-devops#linux).

Since the poor Features of this Image where pretty unsatisfying, I added some more:

* Powershell
* Pulumi-CLI
* Python 3.8.0
  * even made it work with the "UsePythonVersion@0" Task :feelsgood:
* Python 3.6.9 compatibility for "UsePythonVersion@0" Task :godmode:
* tested yet on x64 and ARM64v8, while the Task "UsePythonVersion@0" only works on x64 :sob:

## Why

Helpful if you cannot use the public available Build-Agents or any other Reason to run a private build-agent.

## How

To run the Agent locally, you should first create a `.env` file with at least this content:

``` dotenv
AZP_URL=<Azure DevOps instance>
AZP_TOKEN=<PAT token>
```

Then you can use the included script `run-local.sh` to run the container, or build it by yourself via `build.sh` or manually.

### necessary env

* `AZP_URL`: The URL of the Azure DevOps or Azure DevOps Server instance.
* `AZP_TOKEN`: Personal Access Token (PAT) with Agent Pools (read, manage) scope, created by a user who has permission to configure agents, at `AZP_URL`.

### optional env

* `AZP_AGENT_NAME`: Agent name (default value: the container hostname).
* `AZP_POOL`: Agent pool name (default value: Default)
* `AZP_WORK`: Work directory (default value: _work)
