#!/bin/bash

api=`find . -name 'config.sh' | head -n1`
DIR=`${api} --get DIR`

NO_GIT=0
for param in "$@"; do
    if [ "${param}" = "--no-git" ]; then
        NO_GIT=1
        echo "Disabling Git Updates" 1>&2
    else
        echo "ERROR: Uncrecognized option \"${param}\"" 1>&2
        exit 1
    fi
done

is_repo=0
if [ "${NO_GIT}" -eq 0 ]; then
    if [ ! -z `which git` ]; then
        git status 2>/dev/null 1>/dev/null
        if [ "$?" -eq 0 ]; then
            is_repo=1
        fi
    fi
fi

version_name=`${api} --get VERSION`
version_code=`${api} --get VERSION_CODE`

echo "Current Version Code: ${version_code}"
echo "Current Version Name: ${version_name}"

echo -n 'New Version Name: '
read new_version_name
echo -e '\033[1A\033[2K' # Clear the read input from the screen...

new_version_code=$(( ${version_code} + 1 ))

echo "New Version Code: ${new_version_code}"
echo "New Version Name: ${new_version_name}"

echo "${DIR}AndroidManifest.xml..."
sed -i '' "s/\(.*android:versionCode=\"\)[0-9]\+\(\".*\)/\1${new_version_code}\2/g" "${DIR}AndroidManifest.xml"
sed -i '' "s/\(.*android:versionName=\"\)[0-9\.]\+\(\".*\)/\1${new_version_name}\2/g" "${DIR}AndroidManifest.xml"

if [ "${is_repo}" -gt 0 ]; then
    git add "${DIR}AndroidManifest.xml" 2>/dev/null
fi

echo "${DIR}pom.xml"
sed -i '' "0,/.*<version>[0-9\.]\+<\/version>.*/{s/\(.*<version>\)[0-9\.]\+\(<\/version>.*\)/\1$new_version_name\2/}" "${DIR}pom.xml"
if [ "${is_repo}" -gt 0 ]; then
    git add "${DIR}pom.xml" 2>/dev/null
fi

echo "Done."
