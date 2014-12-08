#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be ran as root." 1>&2
    exit 1
fi

api=`find . -name 'config.sh' | head -n1`
SDK_PATH="`${api} --get SDK_PATH`/"

DIR=`${api} --get DIR`

build_tools_version=`find "${DIR}" -name "build.gradle" | xargs grep -i '^[ ]*buildToolsVersion.*$' | awk '{ print tolower($0) }' | sed -n 's/^[ ]*buildtoolsversion[ \"]*\([0-9\.]*\)[ \"]*$/\1/p'`

if [ -z "${build_tools_version}" ]; then
    echo "Cannot automatically detect the Build Tools version." 1>&2
    echo -n "Build Tools Version: (21.0.2) "
    read build_tools_version

    if [ -z "${build_tools_version}" ]; then
        build_tools_version='21.0.2'
    fi
fi

echo "Searching for SDK package..."
package_id=`${SDK_PATH}tools/android list sdk --all | grep -i "build-tools.*${build_tools_version}" | sed -n 's/^[ ]*\([0-9]*\).*/\1/p'`

if [ -z "${package_id}" ]; then
    echo "Cannot find Build Tools Version: ${build_tools_version}" 1>&2
    exit 1
fi

echo "Buid Tools Version: ${build_tools_version} | Package ID: ${package_id}"

${SDK_PATH}tools/android update sdk --no-ui --all --filter "${package_id}"
