#!/bin/bash

# Set to exit script on error
set -e -u 

# Set debug
#set -x

#set -o allexport

export SCRIPTS_COMMON_PATH=./scripts-common/utilities.sh
. "$SCRIPTS_COMMON_PATH"


variableInFile () {
    local variable=${1}
    local file=${2}

    source ${file}
    eval value=\$\{${variable}\}
    echo ${value}
}

readEnvFile () {
    local file=${1}

    if [ ! -f ${file} ]; then
        echo "Unable to read environment file: ${file}"
        exit -1
    fi

    source ${file}
}

checkEnv () {

    if [[ -z "${USERNAME}" ]]; then
        echo "USERNAME not set"
        exit -1
    fi

    if [[ -z "${PASSWORD}" ]]; then
        echo "PASSWORD not set"
        exit -1
    fi

    if [[ -z "${APIKEY}" ]]; then
        echo "APIKEY not set"
        exit -1
    fi

    if [[ -z "${APIKEYSECRET}" ]]; then
        echo "APIKEYSECRET not set"
        exit -1
    fi


    if [[ -z "${AREA}" ]]; then
        echo "AREA not set"
        exit -1
    fi

    if [[ -z "${TM}" ]]; then
        echo "AREA not set"
        exit -1
    fi

    checkBin jq || errorMessage "This tool requires jq. Install it please, and then run this tool again."

}

encode () {
    local key="$1" secret="$2" toEncode="${key}:${secret}"
    RET_VAL=`echo ${toEncode} | base64` 
}

authenticateMashery () {
    info "Authenticating with Mashery"

    local key="$1" 
    local secret="$2" 
    local username="$3" 
    local password="$4" 
    local scope="$5"

    local result=`curl -s --location --request POST 'https://api.mashery.com/v3/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
-u ${key}:${secret} \
--data-urlencode 'grant_type=password' \
--data-urlencode 'username='${username} \
--data-urlencode 'password='${password} \
--data-urlencode 'scope='${scope}`

    if [ $? -ne 0 ]; then
        echo "Failed to authenticate to Mashery"
        exit -1
    fi


    local accessToken=`echo ${result} | jq -r '.access_token'`

    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Mashery Access Token"
        exit -1
    fi

    local refreshToken=`echo ${result} | jq -r '.refresh_token'`

    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Mashery Refresh Token"
        exit -1
    fi
    
    export MASHERY_ACCESS_TOKEN=${accessToken}
    export MASHERY_REFRESH_TOKEN=${refreshToken}
}

importServiceFromFile () {
   

    local token="$1"
    local inFile="$2"

    printf "Importing Service definition from file '${inFile}'\n"
  
    local tempFile=$(mktemp)

    local cmd="curl -s --location --request POST 'https://api.mashery.com/v3/rest/services' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer ${token}' \
--data @${inFile}"

    eval $cmd > ${tempFile}

    if [ $? -ne 0 ]; then
        echo "Failed to extract Service definition from Mashery"
        exit -1
    fi

    cat ${tempFile}
}


#
### MAIN ###
#

# Read environment file
readEnvFile .mashbash/.env

# Check env
checkEnv
 
SERVICE=""
FILENAME=""

if (( $# < 2 ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "usage: import -f <file>\n" >&2
    exit 1
fi


PARAMS=""
while (( "$#" )); do
  case "$1" in
    -s|--service)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        SERVICE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -f|--file)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        FILENAME=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"


# Authenticate with Mashery
authenticateMashery $APIKEY $APIKEYSECRET $USERNAME $PASSWORD $AREA

if [[ ! -z "${FILENAME}" ]]; then
  importServiceFromFile $MASHERY_ACCESS_TOKEN $FILENAME
fi


