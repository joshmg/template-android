#!/bin/bash

api=`find . -name 'config.sh' | head -n1`
DIR=`${api} --get DIR`
APPLICATION=`${api} --get APPLICATION`
application=`echo ${APPLICATION} | awk '{print tolower($0)}'`
VERSION=`${api} --get VERSION`

KEYSTORE_DIR="${DIR}util/keystore/"
KEYSTORE_FILE="${KEYSTORE_DIR}__company__.keystore"
KEYSTORE="${application}-keystore"

CREATE_KEYSTORE=0
for param in "$@"; do
    if [ "${param}" = "--init" ]; then
        CREATE_KEYSTORE=1
    else
        echo "ERROR: Uncrecognized option \"${param}\"" 1>&2
        exit 1
    fi
done

if [ "${CREATE_KEYSTORE}" -gt 0 ]; then
    if [ ! -d "${KEYSTORE_DIR}" ]; then
        mkdir "${KEYSTORE_DIR}"
    fi

    
    if [ -z `which keytool` ]; then
        echo "ERROR: keytool not found." 1>&2
        exit 1
    fi

    keytool -genkey -v -keystore "${KEYSTORE_FILE}" -alias "${KEYSTORE}" -keyalg RSA -keysize 2048 -validity 10000

    exit 0
fi

if [ -z `which jarsigner` ]; then
    echo "ERROR: jarsigner not found." 1>&2
    exit 1
fi

if [ ! -f "${KEYSTORE_FILE}" ]; then
    echo "ERROR: No keystore found. (Try running: '$0 --init')" 1>&2
    exit 1
fi

echo -n "Keystore Password: "
read -s keystore_password
echo

echo "${keystore_password}" | jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore "${KEYSTORE_FILE}" "${DIR}target/${application}-${VERSION}.apk" "${KEYSTORE}" >/dev/null 2>/dev/null

if [ "$?" -gt 0 ]; then
    echo "Error signing app!" 1>&2
    exit 1
fi

signed=`jarsigner -verify -certs "${DIR}target/${application}-${VERSION}.apk"`

if [ "$?" -eq 0 ] && [ -z "`echo \"${signed}\" | grep \"unsigned\"`" ]; then
    echo "App signed!" 1>&2
    exit 0
else
    echo "App NOT signed!" 1>&2
    exit 1
fi
