#!/bin/bash

api=`find . -name 'config.sh' | head -n1`
SDK_PATH="`${api} --get SDK_PATH`/"

GOOGLE_API=''
DEFAULT_GOOGLE_API='19'

AVD_LABEL=''

DIR=`${api} --get DIR`
AVD_DIR="${DIR}util/avd/"

DEFAULT_ABI='google_apis/x86_64'

for param in "$@"; do
    if [ "${param:0:6}" = "--api=" ]; then
        GOOGLE_API=${param:6:${#param}-6}
    elif [ "${param:0:8}" = "--label=" ]; then
        AVD_LABEL=${param:8:${#param}-8}
    fi
done

if [ -z "${GOOGLE_API}" ]; then
    echo "WARN: Google API not set. Using default API level ${DEFAULT_GOOGLE_API}" 1>&2
    GOOGLE_API="${DEFAULT_GOOGLE_API}"
fi

if [ -z "${AVD_LABEL}" ]; then
    default_avd_label="android_api_${GOOGLE_API}"
    echo "WARN: AVD label not set. Using: ${default_avd_label}" 1>&2
    AVD_LABEL="${default_avd_label}"
fi

# if [ ! -d "${AVD_DIR}" ]; then
#     mkdir "${AVD_DIR}"
# fi

target_id=`${SDK_PATH}tools/android list targets | grep "id:.*APIs:${GOOGLE_API}" | sed -n 's/id: \([0-9]*\).*/\1/p' | head -n1`

if [ -z "${target_id}" ]; then
    echo "ERROR: Google API \"${GOOGLE_API}\" not found." 1>&2
    exit 1
fi

${SDK_PATH}tools/android delete avd --name "${AVD_LABEL}" 2>/dev/null
echo "Creating Android Virtual Device using Google API: ${GOOGLE_API} (Target ID: ${target_id}) (Label: ${AVD_LABEL})"  # (Location: \"${AVD_DIR}${AVD_LABEL}\")"
${SDK_PATH}tools/android create avd -n "${AVD_LABEL}" -t ${target_id} --abi "${DEFAULT_ABI}"                            # -p "${AVD_DIR}${AVD_LABEL}"

result=$?
if [ "${result}" -eq 0 ]; then
    echo "Done."
    echo
fi
