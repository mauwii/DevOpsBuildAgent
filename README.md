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

So I will not waste any more time to write some incomplete changelogs or anything and directly jump back to action while you cross your fingers that it will work out :godmode:

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
