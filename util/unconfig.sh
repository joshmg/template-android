#!/bin/bash

############### OPTIONAL CONFIG ###############
COMPANY_NEEDLE='__COMPANY__'
APPLICATION_NEEDLE='__APPLICATION__'
SDK_PATH_NEEDLE='__SDK_PATH__'
SKIP_FILES=''
###############################################

###############################################
###############################################

this=`echo "$0" | sed 's/[^a-zA-Z]\+\([a-zA-Z\.]\+\).*/\1/p' | tail -n1`
api=`find . -name 'config.sh' | head -n1`

# ${api} --no-git --needle="${APPLICATION_NEEDLE}" --sdk-needle="${SDK_PATH_NEEDLE}" --skip="${this} ${SKIP_FILES}"

# ./install.sh
# mvn clean

${api} --no-git --company-needle="`${api} --get COMPANY`" --needle="`${api} --get APPLICATION`" --sdk-needle="`${api} --get SDK_PATH`" --sdk-path="${SDK_PATH_NEEDLE}" --company="${COMPANY_NEEDLE}" --application-name="${APPLICATION_NEEDLE}" --skip="`${api} --get SKIP_FILES`"

