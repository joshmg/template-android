#!/bin/bash

api=`find . -name 'config.sh' | head -n1`

DIR=`${api} --get DIR`
APPLICATION=`${api} --get APPLICATION`
application=`echo ${APPLICATION} | awk '{print tolower($0)}'`
VERSION=`${api} --get VERSION`

adb='adb'
if [ -z `which adb` ]; then
    SDK_PATH="`${api} --get SDK_PATH`/"
    if [ -x "${SDK_PATH}/platform-tools/adb" ]; then
        adb="${SDK_PATH}/platform-tools/adb"
    else
        echo "ERROR: adb not found. Consider symlinking it to /usr/bin from your sdk directory." 1>&2
        echo "Example: sudo ln -s <sdk-directory>/platform-tools/adb /usr/bin" 1>&2
        exit 1
    fi
fi

SIGN=0
SIGN_DEBUG=1
ZIP_ALIGN=0
RELEASE_MODE='false'
for param in "$@"; do
    if [ "${param}" = "--production" ]; then
        RELEASE_MODE='true'
        SIGN=1
        SIGN_DEBUG=0
        ZIP_ALIGN=1
        echo "NOTICE: Preparing for Production release. (Signed and Zip-Aligned)" 1>&2
        break
    elif [ "${param}" = "--sign" ]; then
        SIGN=1
        SIGN_DEBUG=0
        echo "NOTICE: APK will be signed with the production key." 1>&2
    elif [ "${param}" = "--no-sign" ]; then
        SIGN=0
        SIGN_DEBUG=0
        echo "NOTICE: APK will not be signed with any key." 1>&2
    elif [ "${param}" = "--align" ]; then
        ZIP_ALIGN=1
        echo "NOTICE: APK will be zip-aligned." 1>&2
    else
        echo "ERROR: Uncrecognized option \"${param}\"" 1>&2
        exit 1
    fi
done

function zip_align() {
    mv ${DIR}target/${application}-${VERSION}.apk                   \
        ${DIR}target/${application}-${VERSION}-unaligned.apk    &&  \
    ${SDK_PATH}/build-tools/20.0.0/zipalign -f 4                    \
        ${DIR}target/${application}-${VERSION}-unaligned.apk        \
        ${DIR}target/${application}-${VERSION}.apk              &&  \
    rm ${DIR}target/${application}-${VERSION}-unaligned.apk

    return $?
}

sign_with_debug='true'
if [ "${SIGN}" -gt 0 ] || [ "${SIGN_DEBUG}" -eq 0 ]; then
    sign_with_debug='false'
fi

mvn package -Dandroid.release=${RELEASE_MODE} -Dandroid.sign.debug=${sign_with_debug} || exit 1

if [ "${SIGN}" -gt 0 ]; then
    ${DIR}util/sign_apk.sh || exit 1
fi

if [ "${ZIP_ALIGN}" -gt 0 ]; then
    zip_align || exit 1
fi

if [ "${SIGN}" -gt 0 ] || [ "${SIGN_DEBUG}" -gt 0 ]; then
    ${adb} wait-for-device                                          &&  \
    ${adb} uninstall com.__company__.${application}               &&  \
    ${adb} install ${DIR}target/${application}-${VERSION}.apk
fi
