#!/usr/bin/env bash
set -e

# Step 1 - prepare
export baseos='linux'
export baseDistro='ubuntu'
export baseVersion='18.04'
export basetag='mauwii/devopsbuildagent'

build_image() {
  export DOCKER_DEFAULT_PLATFORM="${baseos}/${targetproc}"
  docker build \
    --build-arg="targetarch=${baseos}-${targetarch}" \
    --build-arg="baseimage=${targetproc}/${baseDistro}:${baseVersion}" \
    --tag "${basetag}:${baseos}-${targetarch}" .
}

# STEP 2 - build container images amd64 and arm64v8
# begin with amd64
export targetproc='amd64'
export targetarch='x64'
build_image

# then build the arm64 image
export targetarch='arm64'
export targetproc="${targetarch}v8"
build_image

# STEP 3 push images to registry
# docker push "${basetag}"
docker push "${basetag}:${baseos}-x64"
docker push "${basetag}:${baseos}-arm64v8"

# STEP 4 - create and push manifest
docker manifest create --amend ${basetag}:latest ${basetag}:${baseos}-x64 ${basetag}:${baseos}-arm64v8
docker manifest annotate ${basetag}:latest ${basetag}:${baseos}-x64 --os ${baseos} --arch amd64
docker manifest annotate ${basetag}:latest ${basetag}:${baseos}-arm64v8 --os ${baseos} --arch arm64 --variant v8
docker manifest push --purge ${basetag}:latest
