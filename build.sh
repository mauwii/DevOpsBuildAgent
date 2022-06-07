#!/usr/bin/env bash
set -e

# check command arguments if exists
for argument in "$@"; do
  # Disable Distribution - usefull when experimenting locally
  [[ "$argument" = "--nodist" ]] && export nodist=1 && echo "distribution will be skipped \n"
  # Dont build amd64 - usefull since this one is already working
  [[ "$argument" = "--noamd64" ]] && export noamd64=1 && echo "Not building amd64 \n"
  # Dont build arm64 - would be unfair to only opt-out amd64
  [[ "$argument" = "--noarm64" ]] && export noarm64=1 && echo "Not building amd64 \n"
done

# Declare base-env
export baseos='linux'
export baseDistro='ubuntu'
export baseVersion='20.04'
export dockerRegistry='docker.io'
export dockerhubuser='mauwii'
export dockerimage='devopsbuildagent'
export dockerrepository="${dockerhubuser}/${dockerimage}"
export builtTags=()
export builtPlatformOs=()
export builtPlatformArch=()

# create build function
build_image() {
  export DOCKER_DEFAULT_PLATFORM="${dockerdefaultplatformos:-$baseos}/${dockerdefaultplatformarch}"
  export tag="${dockerrepository}:${dockerdefaultplatformos:-$baseos}.${baseDistro}.${baseVersion}.${dockerdefaultplatformarch}.${targetproc}"
  docker build \
  --platform="${dockerdefaultplatformos:-$baseos}/${platformarch}" \
  --build-arg="targetarch=${targetos:-$baseos}-${targetproc}" \
  --tag "${tag}" . \
  && builtTags+=("${tag}") \
  && builtPlatformOs+=("${dockerdefaultplatformos:-$baseos}") \
  && builtPlatformArch+=("${platformarch}") \
  && [[ ${nodist} != 1 ]] && docker push ${tag}
}

if [[ $noamd64 != 1 ]]; then
  export dockerdefaultplatformarch='amd64'
  export platformarch='x86_64'
  export targetproc='x64'
  build_image
fi

if [[ $noarm64 != 1 ]]; then
  export dockerdefaultplatformarch='arm64'
  export platformarch='arm64'
  export targetproc='x64'
  build_image
fi

# Output built Images
echo "Images built: \n ${builtTags[@]}"

# create and push Manifest
if [[ $nodist != 1 ]]; then
  docker manifest create "${dockerrepository}:latest" "${builtTags[@]}"
  i=1
  for tag in "${builtTags[@]}"; do
    docker manifest annotate "${dockerrepository}:latest" "${tag}" --os "${builtPlatformOs[$i]}" --arch "${builtPlatformArch[$i]}"
    i=${i}+1
  done
  docker manifest push --purge "${dockerrepository}:latest"
fi
