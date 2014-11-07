#!/bin/bash

api=`find . -name 'config.sh' | head -n1`

APPLICATION=`${api} --get APPLICATION`
SDK_PATH="`${api} --get SDK_PATH`/"

application=`echo ${APPLICATION} | awk '{print tolower($0)}'`

${SDK_PATH}platform-tools/adb logcat System.out:I ActivityManager:I AndroidRuntime:I com.__company__.util:D com.__company__.${application}:D *:S
