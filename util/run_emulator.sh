#!/bin/bash

api=`find . -name 'config.sh' | head -n1`
SDK_PATH="`${api} --get SDK_PATH`/"

AVD_LABEL=''

DIR=`${api} --get DIR`
# AVD_DIR="${DIR}util/avd/"
AVD_DIR="${HOME}/.android/avd"

for param in "$@"; do
    if [ "${param:0:6}" = "--list" ]; then
        echo "Available AVDs:"
        list=`ls "${AVD_DIR}" 2>/dev/null`
        filtered_list=''
        for file in "${list}"; do
            filtered_list=`echo "${filtered_list}\`echo "${file}" | sed -n 's/^\([^\.]*\)\..*/\1/p'\`"`
        done

        avd_count=0
        list=`echo "${filtered_list}" | uniq`
        for avd in "${list}"; do
            if [ ! -z "${avd}" ]; then
                echo "    ${avd}"
                avd_count=$(( ${avd_count} + 1))
            fi
        done

        if [ "${avd_count}" -eq 0 ]; then
            echo "    [NONE]"
            echo "Create an AVD via: ${DIR}util/create_emulator.sh"
        fi

        exit 1
    else 
        AVD_LABEL=${param}
    fi
done

if [ -z "${AVD_LABEL}" ]; then
    echo "ERROR: Invalid label. Usage: \"$0 <label>\"" 1>&2
    echo "    List all labels via \"$0 --list\"" 1>&2
    exit 1
fi

echo "######################## NOTICE ########################"
echo "Be sure you have installed the x86 AVD accelerator."
echo "Located within:"
echo "    ${SDK_PATH}extras/intel/Hardware_Accelerated_Execution_Manager/"
echo "########################################################"

echo "Starting emulator."
${SDK_PATH}tools/emulator -avd "${AVD_LABEL}" &

