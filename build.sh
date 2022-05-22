#!/usr/bin/env bash

# STEP 1 - build images for two architectures
export DOCKER_DEFAULT_PLATFORM="linux/amd64"
docker build --build-arg='TARGETARCH=linux-x64' --tag mauwii/devopsbuildagent --tag mauwii/devopsbuildagent:linux-x64 .
export DOCKER_DEFAULT_PLATFORM="linux/arm64"
docker build --build-arg='TARGETARCH=linux-arm64' --tag mauwii/devopsbuildagent:linux-arm64 .

# STEP 2 push images to registry
docker push mauwii/devopsbuildagent
docker push mauwii/devopsbuildagent:linux-x64
docker push mauwii/devopsbuildagent:linux-arm64

# STEP 3 - create and push manifest
docker manifest create mauwii/devopsbuildagent:latest mauwii/devopsbuildagent:linux-x64 mauwii/devopsbuildagent:linux-arm64
docker manifest annotate mauwii/devopsbuildagent:latest mauwii/devopsbuildagent:linux-x64 --os linux --arch amd64
docker manifest annotate mauwii/devopsbuildagent:latest mauwii/devopsbuildagent:linux-arm64 --os linux --arch arm64 --variant v8
docker manifest push --purge mauwii/devopsbuildagent:latest
