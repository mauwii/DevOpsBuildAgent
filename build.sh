#!/usr/bin/env bash
set -e

# check command arguments if exists
for argument in "$@"; do
  # Disable Distribution - usefull when experimenting locally
  if [[ "$argument" == "--nodist" ]]; then
    nodist=1
    echo -e "\ndistribution will be skipped - have fun experimenting ;)\n"
  fi
  # Dont build amd64 - usefull since this one is already working
  if [[ "$argument" == "--noamd64" ]]; then
    noamd64=1
    echo -e "will skip building amd64\n"
  fi
  # Dont build arm64 - would be unfair to only opt-out amd64
  if [[ "$argument" == "--noarm64" ]]; then
    noarm64=1
    echo -e "will skip building arm64\n"
  fi
  # Update the Readme located on Dockerhub
  if [[ "$argument" == "--updateReadme" ]]; then
    updateReadme=1
    echo -e "Will update Readme if previous Steps did not fail\n"
  fi
  # can be used to not loose current prod/dev containers built by pipeline
  if [[ "$argument" == "--local" ]]; then
    DEVTAG=local
  fi
done

# Declare base-env
baseOS='linux'
baseDistro='ubuntu'
baseVersion='20.04'
dockerRegistry='docker.io'
dockerhubuser='mauwii'
dockerimage='devopsbuildagent'
dockerrepository="${dockerhubuser}/${dockerimage}"
builtTags=()
builtPlatformOs=()
builtPlatformArch=()

# create build function
build_image() {
  DOCKER_DEFAULT_PLATFORM="${dockerdefaultplatformos:-$baseOS}/${BASEARCH}${BASEARCHVARIANT:+$BASEARCHVARIANT}"
  tag="${dockerrepository}:${dockerdefaultplatformos:-$baseOS}.${baseDistro}.${baseVersion}.${BASEARCH}${BASEARCHVARIANT:+$BASEARCHVARIANT}${DEVTAG:+.$DEVTAG}"
  echo -e "going to build ${tag}\n"
  docker build \
    --platform="${baseOS}/${BASEARCH}${BASEARCHVARIANT:+/$BASEARCHVARIANT}" \
    --build-arg="BASEARCH=${BASEARCH}${BASEARCHVARIANT:+$BASEARCHVARIANT}" \
    --build-arg="targetos=${targetos:-$baseOS}" \
    --build-arg="targetproc=${targetproc}" \
    --tag "${tag}" . \
  && builtTags+=("${tag}") \
  && builtPlatformOs+=("${dockerdefaultplatformos:-$baseOS}") \
  && builtPlatformArch+=("${BASEARCH:+--arch $BASEARCH} ${BASEARCHVARIANT:+--variant $BASEARCHVARIANT}") \
  && [[ $nodist -ne 1 ]] && docker push ${tag} || echo
}

# Build amd64 image if not disabled
if [[ $noamd64 -ne 1 ]]; then
  BASEARCH='amd64' targetproc='x64' build_image
fi

# build arm64v8 if not disabled
if [[ $noarm64 -ne 1 ]]; then
  BASEARCH='arm64' BASEARCHVARIANT='v8' targetproc="${BASEARCH}" build_image
fi

# Output built Images
[[ ${#builtTags[@]} -gt 0 ]] && echo -e "Images built:\n ${builtTags[@]}" || echo -e "Did not build any image."

# create and push Manifest
if [[ $nodist -ne 1 ]]; then
  docker manifest create "${dockerrepository}:latest" "${builtTags[@]}"
  i=1
  for tag in "${builtTags[@]}"; do
    docker manifest annotate "${dockerrepository}:latest" "${tag}" --os "${builtPlatformOs[$i]}" ${builtPlatformArch[$i]}
    i=${i}+1
  done
  docker manifest push --purge "${dockerrepository}:latest"
fi

# Update Readme in Docker hub - needs your password in env as $dockersecret
if [[ $updateReadme -eq 1 ]]; then
  DOCKER_DEFAULT_PLATFORM=linux/amd64
  docker run --rm -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME="${dockerhubuser}" \
    -e DOCKERHUB_PASSWORD="${dockersecret}" \
    -e DOCKERHUB_REPOSITORY="${dockerrepository}" \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:2.1.0
fi
