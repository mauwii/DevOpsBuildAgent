#!/usr/bin/env bash

if [[ "$(arch)" = "arm64" ]]; then
  TARGETARCH="linux-arm64"
else
  TARGETARCH="linux-x64"
fi

echo "set TARGETARCH to ${TARGETARCH}"

docker run --rm \
  -e TARGETARCH="${TARGETARCH}" \
  --env-file ./.env \
  mauwii/devopsbuildagent:latest
