#!/usr/bin/env bash

# if you are not using direnv, dotenv or similar,
# please uncomment and fill out the next 2 settings

# azureDevopsInstance=""
# patToken=""

AZP_AGENT_NAME=mydockeragent
AZP_POOL=local

if [[ "$(arch)" = "arm64" ]]; then
  tag="arm64"
  TARGETARCH="linux-arm64"
fi

echo "going to run devopsbuildagent:${tag:-latest}"
echo "adding agent ${AZU_AGENT_NAME} to ${AZP_POOL}"

docker run --rm \
  -e TARGETARCH="${TARGETARCH}" \
  -e AZP_URL="${azureDevopsInstance}" \
  -e AZP_TOKEN="${patToken}" \
  -e AZP_AGENT_NAME=mydockeragent \
  -e AZP_POOL=local \
  mauwii/devopsbuildagent:${tag:-latest}
