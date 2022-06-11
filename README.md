# DevOpsBuildAgent

[![Build Status](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo/_apis/build/status/devopsbuildagent.yml?branchName=main)](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo/_build/latest?definitionId=15&branchName=main)

## What

This is a Dockerimage to create and run a Linux based Agent for Azure-DevOps which initially got created as described [here](https://docs.microsoft.com/azure/devops/pipelines/agents/docker?view=azure-devops#linux).

Since the poor Features of this Image where pretty unsatisfying, I added some more:

* Azure-CLI MultiArch-compatibility
* Powershell v7.2.4
* Python 3.8.10 with added compatibility for "UsePythonVerison@0" Task
* Python 3.9.5 compatibility for "UsePythonVersion@0" Task
* MultiArch Builds for x64 and arm64v8

## Why

The Agent can be very useful if you can not use the public available Build-Agents or any other Reason to run a private build-agent.

## How

To run the Agent locally, you should first create a `.env` file with at least this content:

``` dotenv
AZP_URL=<Azure DevOps instance>
AZP_TOKEN=<PAT token>
```

Then you can use the included script `run-local.sh` to run the container, or build it by yourself via `build.sh` or manually. For more advanced methods to run the agent, like in a Kubernetes, just have a look in the [official Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#use-azure-kubernetes-service-cluster).

### necessary env

* `AZP_URL`: The URL of the Azure DevOps or Azure DevOps Server instance.
* `AZP_TOKEN`: Personal Access Token (PAT) with Agent Pools (read, manage) scope, created by a user who has permission to configure agents, at `AZP_URL`.

### optional env

* `AZP_AGENT_NAME`: Agent name (default value: the container hostname).
* `AZP_POOL`: Agent pool name (default value: Default)
* `AZP_WORK`: Work directory (default value: _work)

## Tag

The Tag of the Build Agent's Image now contains a lot of useful Information. Let's look at a example first:

```text
mauwii/devopsbuildagent:linux.ubuntu.20.04.arm64v8.142
< 1  >/<--    2     -->:< 3 >.<  4 >.< 5 >.<  6  >.<7>
```

1. The first part is the username of the Creator
2. followed by the image name
3. Base-Image OS
4. Base-Image Distribution
5. Distribution Release
6. Base-Image Architecture
7. BuildId so that you can stick to a Version after new a new release has come
