#!/bin/bash

################### CONFIG ####################
APPLICATION='ExampleApplication'
COMPANY='ExampleCompany'
###############################################


############### OPTIONAL CONFIG ###############
DIR="`pwd`/"
SDK_PATH="${DIR}sdk"

APPLICATION_NEEDLE='__APPLICATION__'
COMPANY_NEEDLE='__COMPANY__'
SDK_PATH_NEEDLE='__SDK_PATH__'
NO_GIT=0
SKIP_FILES=''
###############################################


###############################################
###############################################

this=`echo "$0" | sed 's/[^a-zA-Z]\+\([a-zA-Z\.]\+\).*/\1/p' | tail -n1`
DEFAULT_SKIP_FILES="${this} .git target util"

GET_MODE=0
GET_KEY=''
for param in "$@"; do
    if [ "${param:0:5}" = "--get" ]; then
        GET_MODE=1
    elif [ "${param:0:2}" != "--" ]; then
        GET_KEY="${param}"
    fi
done
if [ "${GET_MODE}" -gt 0 ]; then
    if [ "$#" -gt 3 ]; then
        echo "ERROR: Unrecognized option with GET command." 1>&2
        exit 1
    fi

    GET_KEY=`echo ${GET_KEY} | awk '{print toupper($0)}'`
    SKIP_FILES="${DEFAULT_SKIP_FILES} ${SKIP_FILES}"

    case "${GET_KEY}" in
        APPLICATION)
            echo "${APPLICATION}"
            exit 0
        ;;
        COMPANY)
            echo "${COMPANY}"
            exit 0
        ;;
        DIR)
            echo "${DIR}"
            exit 0
        ;;
        SDK_PATH)
            echo "${SDK_PATH}"
            exit 0
        ;;
        APPLICATION_NEEDLE)
            echo "${APPLICATION_NEEDLE}"
            exit 0
        ;;
        SDK_PATH_NEEDLE)
            echo "${SDK_PATH_NEEDLE}"
            exit 0
        ;;
        NO_GIT)
            echo "${NO_GIT}"
            exit 0
        ;;
        SKIP_FILES)
            echo "${SKIP_FILES}"
            exit 0
        ;;
        VERSION)
            version_name=`sed -n 's/.*android:versionName="\([0-9\.]\+\)".*/\1/p' "${DIR}AndroidManifest.xml"`
            echo "${version_name}"
            exit 0
        ;;
        VERSION_CODE)
            version_code=`sed -n 's/.*android:versionCode="\([0-9]\+\)".*/\1/p' "${DIR}AndroidManifest.xml"`
            echo "${version_code}"
            exit 0
        ;;
        *)
            echo "ERROR: Invalid GET request. Key not found: \"${GET_KEY}\"" 1>&2
            echo "Usage: $0 --get <APPLICATION|COMPANY|DIR|SDK_PATH|APPLICATION_NEEDLE|SDK_PATH_NEEDLE|NO_GIT|SKIP_FILES|VERSION|VERSION_CODE> " 1>&2
            exit 1
    esac
fi

for param in "$@"; do
    if [ "${param:0:19}" = "--application-name=" ]; then
        APPLICATION="${param:19}"
        echo "Using Application Name: ${APPLICATION}" 1>&2
    elif [ "${param:0:10}" = "--company=" ]; then
        COMPANY="${param:11}"
        echo "Using SDK Path: ${SDK_PATH}" 1>&2
    elif [ "${param:0:11}" = "--sdk-path=" ]; then
        SDK_PATH="${param:11}"
        echo "Using SDK Path: ${SDK_PATH}" 1>&2
    elif [ "${param}" = "--no-git" ]; then
        NO_GIT=1
        echo "Disabling Git Updates" 1>&2
    elif [ "${param:0:9}" = "--needle=" ]; then
        APPLICATION_NEEDLE="${param:9}"
        echo "Using Application Needle: ${APPLICATION_NEEDLE}" 1>&2
    elif [ "${param:0:13}" = "--sdk-needle=" ]; then
        SDK_PATH_NEEDLE="${param:13}"
        echo "Using SDK Path Needle: ${SDK_PATH_NEEDLE}" 1>&2
    elif [ "${param:0:7}" = "--skip=" ]; then
        SKIP_FILES="${param:7}"
        echo "Skipping files: ${SKIP_FILES}" 1>&2
    else
        echo "ERROR: Uncrecognized option \"${param}\"" 1>&2
        exit 1
    fi
done

function escape_sed() {
    echo "$@" | sed 's/\//\\\//g' | tail -n1
}

function skip_file() {
    file="$1"

    if [ "${file:0:2}" = "./" ]; then
        file="${file:2}"
    fi

    for skip_file in ${SKIP_FILES}; do
        echo "${file}" | grep "^${skip_file}" >/dev/null 2>/dev/null
        if [ "$?" -eq 0 ]; then
            echo 1
            return
        fi
    done

    echo 0
}

cd "${DIR}" >/dev/null

SKIP_FILES="${DEFAULT_SKIP_FILES} ${SKIP_FILES}"
application=`echo ${APPLICATION} | awk '{print tolower($0)}'`
application_needle=`echo "${APPLICATION_NEEDLE}" | awk '{print tolower($0)}'`
company_needle=`echo "${COMPANY_NEEDLE}" | awk '{print tolower($0)}'`
company=`echo ${COMPANY} | awk '{print tolower($0)}'`

is_repo=0
if [ "${NO_GIT}" -eq 0 ]; then
    if [ ! -z `which git` ]; then
        git status 2>/dev/null 1>/dev/null
        if [ "$?" -eq 0 ]; then
            is_repo=1
        fi
    fi
fi

for file in `grep -rl "${application_needle}" --exclude-dir="sdk" .`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        sed -i '' "s/${application_needle}/${application}/g" "${file}"
        if [ "${is_repo}" -gt 0 ]; then
            git add "${file}" 2>/dev/null
        fi
    fi
done

for file in `grep -rl "${APPLICATION_NEEDLE}" --exclude-dir="sdk" .`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        sed -i '' "s/${APPLICATION_NEEDLE}/${APPLICATION}/g" "${file}"
        if [ "${is_repo}" -gt 0 ]; then
            git add "${file}" 2>/dev/null
        fi
    fi
done

for file in `grep -rl "${company_needle}" --exclude-dir="sdk" .`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        sed -i '' "s/${company_needle}/${company}/g" "${file}"
        if [ "${is_repo}" -gt 0 ]; then
            git add "${file}" 2>/dev/null
        fi
    fi
done

for file in `grep -rl "${COMPANY_NEEDLE}" --exclude-dir="sdk" .`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        sed -i '' "s/${COMPANY_NEEDLE}/${COMPANY}/g" "${file}"
        if [ "${is_repo}" -gt 0 ]; then
            git add "${file}" 2>/dev/null
        fi
    fi
done

# sdk_path=`echo "${SDK_PATH}" | sed 's/\//\\\\\//g' | tail -n1`
for file in `grep -rl "${SDK_PATH_NEEDLE}" --exclude-dir="sdk" .`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        sed_string="s/`escape_sed \"${SDK_PATH_NEEDLE}\"`/`escape_sed \"${SDK_PATH}\"`/g"
        sed -i '' "${sed_string}" "${file}"
        if [ "${is_repo}" -gt 0 ]; then
            git add "${file}" 2>/dev/null
        fi
    fi
done

for file in `find . -name "*${application_needle}*"`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        new_file=`echo ${file} | sed "s/${application_needle}/${application}/g"`
        if [ "${is_repo}" -gt 0 ]; then
            git mv ${file} ${new_file}
        else
            mv ${file} ${new_file}
        fi
    fi
done

for file in `find . -name "*${APPLICATION_NEEDLE}*"`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        new_file=`echo ${file} | sed "s/${APPLICATION_NEEDLE}/${APPLICATION}/g"`
        if [ "${is_repo}" -gt 0 ]; then
            git mv ${file} ${new_file}
        else
            mv ${file} ${new_file}
        fi
    fi
done

for file in `find . -name "*${company_needle}*"`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        new_file=`echo ${file} | sed "s/${company_needle}/${company}/g"`
        if [ "${is_repo}" -gt 0 ]; then
            git mv ${file} ${new_file}
        else
            mv ${file} ${new_file}
        fi
    fi
done

for file in `find . -name "*${COMPANY_NEEDLE}*"`; do
    if [ `skip_file "${file}"` -eq 0 ]; then
        new_file=`echo ${file} | sed "s/${COMPANY_NEEDLE}/${COMPANY}/g"`
        if [ "${is_repo}" -gt 0 ]; then
            git mv ${file} ${new_file}
        else
            mv ${file} ${new_file}
        fi
    fi
done

cd - >/dev/null

