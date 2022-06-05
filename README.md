# DevOpsBuildAgent

## What

This is a Dockerimage to create and run a Linux based Agent for Azure-DevOps which initially got created as described [here](https://docs.microsoft.com/azure/devops/pipelines/agents/docker?view=azure-devops#linux).

Since the poor Features of this Image where pretty unsatisfying, I added some more:

* Powershell
* Pulumi-CLI
* Python 3.8.0
  * even made it work with the "UsePythonVersion@0" Task :feelsgood:
* Python 3.6.9 compatibility for "UsePythonVersion@0" Task :godmode:
* tested yet on x64 and ARM64v8, while UsePythonVersion only works on x64 :sob:

## Why

Helpful if you cannot use the public available Build-Agents or any other Reason to run a private build-agent.

## Run Agent local

To run the Agent locally, create a `.env` file with following content:

``` dotenv
AZP_URL=<Azure DevOps instance>
AZP_TOKEN=<PAT token>
```

Then you can use the included script `run-local.sh` to run the container.

### necessary env-vars

* `AZP_URL`: The URL of the Azure DevOps or Azure DevOps Server instance.
* `AZP_TOKEN`: Personal Access Token (PAT) with Agent Pools (read, manage) scope, created by a user who has permission to configure agents, at `AZP_URL`.

### optional env-vars

* `AZP_AGENT_NAME`: Agent name (default value: the container hostname).
* `AZP_POOL`: Agent pool name (default value: Default)
* `AZP_WORK`: Work directory (default value: _work)
