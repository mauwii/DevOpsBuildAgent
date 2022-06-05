#!/usr/bin/env bash

export build="ubuntu.18.04"

# if on Apple M1 but still want to use amd64, just add x64 to script execution
# ./run-local.sh x64 - then M1 will be ignored

if [[ "$(arch)" = "arm64" ]] && [[ $1 != "x64" ]]; then
  export DOCKER_DEFAULT_PLATFORM="linux/arm64"
  export tag="${build}.arm64"
else
  export DOCKER_DEFAULT_PLATFORM="linux/amd64"
  export tag="${build}.amd64"
fi

echo "using tag ${tag}"
docker run --rm \
  --env-file ./.env \
  "mauwii/devopsbuildagent:${tag}"
