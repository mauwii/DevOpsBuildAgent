#!/usr/bin/env bash
set -e

# Enable BuildKit
export DOCKER_BUILDKIT=1

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
baseOS="${baseOS:-linux}"
baseDistro="${baseDistro:-ubuntu}"
baseVersion="${baseVersion:-20.04}"
dockerRegistry="${dockerRegistry:-docker.io}"
dockerhubuser="${dockerhubuser:-"$(whoami)"}"
dockerimage="${dockerimage:-devopsbuildagent}"
dockerrepository="${dockerhubuser}/${dockerimage}"
builtTags=()
builtPlatformOs=()
builtPlatformArch=()

# create build function
build_image() {
    # TARGETPLATFORM="${dockerdefaultplatformos:-$baseOS}/${BASE_ARCH}${BASE_ARCH_VARIANT:+/$BASE_ARCH_VARIANT}"
    tag="${dockerrepository}:${dockerdefaultplatformos:-$baseOS}.${baseDistro}.${baseVersion}.${BASE_ARCH}${BASE_ARCH_VARIANT:+$BASE_ARCH_VARIANT}${DEVTAG:+.$DEVTAG}"
    echo -e "going to build ${tag}\n"
    docker build \
        --platform="${dockerdefaultplatformos:-$baseOS}/${BASE_ARCH}${BASE_ARCH_VARIANT:+/$BASE_ARCH_VARIANT}" \
        --build-arg="BASE_ARCH=${BASE_ARCH}${BASE_ARCH_VARIANT:+$BASE_ARCH_VARIANT}" \
        --build-arg="targetos=${targetos:-$baseOS}" \
        --build-arg="targetproc=${targetproc:-x64}" \
        --tag="${tag}" . \
        && builtTags+=("${tag}") \
        && builtPlatformOs+=("${dockerdefaultplatformos:-$baseOS}") \
        && builtPlatformArch+=("${BASE_ARCH:+--arch $BASE_ARCH}${BASE_ARCH_VARIANT:+ --variant $BASE_ARCH_VARIANT}") \
        && (
            [[ $nodist -ne 1 ]] \
                && docker push "${tag}" \
                || echo "did not push ${tag}"
        )
}

# Build amd64 image if not disabled
if [[ $noamd64 -ne 1 ]]; then
    BASE_ARCH='amd64' targetproc='x64' build_image
fi

# build arm64v8 if not disabled
if [[ $noarm64 -ne 1 ]]; then
    BASE_ARCH='arm64' BASE_ARCH_VARIANT='v8' targetproc='arm64' build_image
fi

# Output built Images
[[ ${#builtTags[@]} -gt 0 ]] \
    && echo -e "Images built:\n ${builtTags[*]}" \
    || echo -e "Did not build any image."

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
[[ $updateReadme -eq 1 && -n $dockersecret ]] \
    && DOCKER_DEFAULT_PLATFORM=linux/amd64 \
        docker run \
        --rm \
        -v "$(pwd)":/workspace \
        -e DOCKERHUB_USERNAME="${dockerhubuser}" \
        -e DOCKERHUB_PASSWORD="${dockersecret}" \
        -e DOCKERHUB_REPOSITORY="${dockerrepository}" \
        -e README_FILEPATH='/workspace/README.md' \
        peterevans/dockerhub-description:2.1.0 \
    || echo "did not update Readme"
