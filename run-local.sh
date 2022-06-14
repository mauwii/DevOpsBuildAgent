#!/usr/bin/env zsh
set -e

# check command arguments if exists
for argument in "$@"; do
  # Run Dev/local Container
  if [[ "$argument" == "--dev" ]] || [[ "$argument" == "--local" ]]; then
      if [[ ! -z $devtag ]];then
      echo "cannot use arguments --dev and --local together"
      exit -1
    else
      devtag="${argument/--/}"
    fi
  fi
  if [[ "$argument" == "--x64" ]]; then
    forcex64="1"
  fi
done

baseos='linux'
baseDistro='ubuntu'
baseVersion='20.04'
dockerregistry='docker.io'
dockerhubuser='mauwii'
dockerimage='devopsbuildagent'
dockerrepository="${dockerhubuser}/${dockerimage}"

if [[ "$(arch)" = "arm64" ]] && [[ $forcex64 -ne 1 ]]; then
  dockerdefaultplatformarch='arm64'
  dockerdefaultplatformarchvariant='v8'
  targetproc='arm64'
else
  dockerdefaultplatformarch='amd64'
  targetproc='x64'
fi

DOCKER_DEFAULT_PLATFORM="${baseos}/${dockerdefaultplatformarch}${dockerdefaultplatformarchvariant:+/$dockerdefaultplatformarchvariant}"
tag="${baseos}.${baseDistro}.${baseVersion}.${dockerdefaultplatformarch}${dockerdefaultplatformarchvariant:+$dockerdefaultplatformarchvariant}${devtag:+.$devtag}"
dockerimage="${dockerrepository}:${tag}"

echo -e "going to run ${dockerimage}\n"

docker run --rm --env-file "./.env" "${dockerrepository}:${tag}"
