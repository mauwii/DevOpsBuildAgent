#!/usr/bin/env zsh
set -e

# check command arguments if exists
for argument in "$@"; do
  # Run Dev Container
  if [[ "$argument" == "--dev" ]]; then
    export devtag="dev"
  fi
  # Force execution of x64 Container
  if [[ "$argument" == "--x64" ]]; then
    export forcex64="1"
  fi
done
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
if [[ "$(arch)" = "arm64" ]] && [[ $forcex64 -ne 1 ]]; then
  export dockerdefaultplatformarch='arm64'
  export dockerdefaultplatformarchvariant='v8'
  export targetproc='arm64'
else
  export dockerdefaultplatformarch='amd64'
fi

export DOCKER_DEFAULT_PLATFORM="${baseos}/${dockerdefaultplatformarch}${dockerdefaultplatformarchvariant:+/$dockerdefaultplatformarchvariant}"
export tag="${baseos}.${baseDistro}.${baseVersion}.${dockerdefaultplatformarch}${dockerdefaultplatformarchvariant:+$dockerdefaultplatformarchvariant}.${targetproc}${devtag:+.$devtag}"
export dockerimage="${dockerrepository}:${tag}"

echo -e "going to run ${dockerimage}\n"

docker run --rm \
  --env-file ./.env \
  "${dockerrepository}:${tag}"
