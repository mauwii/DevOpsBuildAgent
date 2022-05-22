#!/usr/bin/env bash

if [[ "$(arch)" = "arm64" ]]; then
  targetarch="linux-arm64"
else
  targetarch="linux-x64"
fi

echo "set TARGETARCH to ${targetarch}"

docker run --rm \
  -e TARGETARCH="${targetarch}" \
  --env-file ./.env \
  mauwii/devopsbuildagent:latest
