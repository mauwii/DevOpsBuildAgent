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
    --build-arg="targetplatform=${baseos}/${targetproc}" \
    --build-arg="targetarch=${baseos}-${targetarch}" \
    --tag "${basetag}:${baseDistro}.${baseVersion}.${targetproc}" \
    --file=Dockerfile.1804 .
  docker push "${basetag}:${baseDistro}.${baseVersion}.${targetproc}"
}

# STEP 2 - build & push amd64 and arm64v8 container images
export targetarch='x64'
export targetproc='amd64'
build_image

export targetarch='arm64'
export targetproc="${targetarch}"
build_image

# STEP 3 - create and push manifest
docker manifest create --amend "${basetag}:latest" "${basetag}:${baseDistro}.${baseVersion}.amd64" "${basetag}:${baseDistro}.${baseVersion}.arm64"
docker manifest annotate "${basetag}:latest" "${basetag}:${baseDistro}.${baseVersion}.amd64" --os "${baseos}" --arch amd64
docker manifest annotate "${basetag}:latest" "${basetag}:${baseDistro}.${baseVersion}.arm64" --os "${baseos}" --arch arm64 --variant v8
docker manifest push --purge "${basetag}:latest"
