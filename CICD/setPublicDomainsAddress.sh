#!/bin/bash

# Set to exit script on error
set -e -u 

# Set debug
#set -x

#set -o allexport


export SCRIPTS_COMMON_PATH=./scripts-common/utilities.sh
. "$SCRIPTS_COMMON_PATH"


main () {

    local endpointName=${1}
    local publicDomainAddress=${2}
    local infile=${3}
    local outfile=${4}

    printf "Setting Public Domain Address '${publicDomainAddress}' for Endpoint '${endpointName}'\n"


    local jqCmd="jq '(.endpoints[] | select(.name == \"${endpointName}\") | select(.publicDomains[].address) | .publicDomains[].address ) |= \"${publicDomainAddress}\"' ${infile} > ${outfile}"

    eval $jqCmd

    if [ $? -ne 0 ]; then
        echo "Failed to replace"
        exit -1
    fi

}

if (( $# != 8 ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "usage: setPublicDomainAddress -e <endpointName> -p <publicDomainAddress> -i <file> -o <file>\n" >&2
    exit 1
fi

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -e|-endpointName)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ENDPOINTNAME=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -p|-pubicDomainAddress)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PUBLICDOMAINADDRESS=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -i|-in)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        INFILE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -o|-out)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OUTFILE=$2
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

main "${ENDPOINTNAME}" ${PUBLICDOMAINADDRESS} ${INFILE} ${OUTFILE}