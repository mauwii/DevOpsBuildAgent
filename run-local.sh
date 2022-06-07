#!/usr/bin/env zsh
set -e

export baseos='linux'
export baseDistro='ubuntu'
export baseVersion='20.04'
export dockerregistry='docker.io'
export dockerhubuser='mauwii'
export dockerimage='devopsbuildagent'
export targetproc='x64'
export dockerrepository="${dockerhubuser}/${dockerimage}"

# if on Apple M1 but still want to use amd64, just add x64 to script execution
# ./run-local.sh x64 - then M1 will be ignored
if [[ "$(arch)" = "arm64" ]] && [[ $1 != "x64" ]]; then
  export dockerdefaultplatformarch='arm64'
else
  export dockerdefaultplatformarch='amd64'
fi

export DOCKER_DEFAULT_PLATFORM="${baseos}/${dockerdefaultplatformarch}"
export tag="${baseos}.${baseDistro}.${baseVersion}.${dockerdefaultplatformarch}.${targetproc}"
export dockerimage="${dockerrepository}:${tag}"

echo "going to run ${dockerimage}\n"

docker run --rm \
  --env-file ./.env \
  "${dockerrepository}:${tag}"
