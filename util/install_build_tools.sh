#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be ran as root." 1>&2
    exit 1
fi

api=`find . -name 'config.sh' | head -n1`
SDK_PATH="`${api} --get SDK_PATH`/"

DIR=`${api} --get DIR`

function list_available_versions() {
    echo "" 1>&2
    echo "Obtaining list of available versions... " 1>&2
    ${SDK_PATH}tools/android list sdk --all | grep -i "build-tools" | awk '{ print tolower($0) }' | sed -n 's/^.*revision[ ]*\([0-9\.]*\).*$/  \1/p' 1>&2
    echo "" 1>&2
}

function prompt_for_build_tools_version() {
    list_available_versions

    echo -n "Build Tools Version: (21.0.2) " 1>&2
    read version 
    echo "${version}"
}

function get_build_tools_version() {
    version=`find "${DIR}" -name "build.gradle"  | xargs grep -i '^[ ]*buildToolsVersion.*$' | awk '{ print tolower($0) }' | sed -n 's/^.*buildtoolsversion[ \"]*\([0-9\.]*\)[ \"]*$/\1/p'`

    if [ -z "${version}" ]; then
        echo "Cannot automatically detect the Build Tools version." 1>&2
        version=`prompt_for_build_tools_version`

        if [ -z "${version}" ]; then
            version='21.0.2'
        fi
    fi

    echo "${version}"
}

function get_sdk_package() {
    version="${1}"

    package_id=`${SDK_PATH}tools/android list sdk --all | grep -i "build-tools.*${version}" | sed -n 's/^[ ]*\([0-9]*\).*/\1/p'`

    if [ -z "${package_id}" ]; then
        echo "Cannot find Build Tools Version: ${version}" 1>&2
        echo "" 1>&2
    else
        echo "${package_id}"
    fi
}

build_tools_version=`get_build_tools_version`
echo "Searching for SDK package..." 1>&2
package_id=`get_sdk_package "${build_tools_version}"`

if [ -z "${package_id}" ]; then

    build_tools_version=`prompt_for_build_tools_version`

    package_id=`get_sdk_package "${build_tools_version}"`

    if [ -z "${package_id}" ]; then
        exit 1
    fi
fi

echo "Buid Tools Version: ${build_tools_version} | Package ID: ${package_id}" 1>&2

${SDK_PATH}tools/android update sdk --no-ui --all --filter "${package_id}"

exit $?
