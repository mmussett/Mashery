#!/bin/bash

# Set to exit script on error
set -e -u 

# Set debug
#set -x

#set -o allexport


export SCRIPTS_COMMON_PATH=./scripts-common/utilities.sh
. "$SCRIPTS_COMMON_PATH"


main () {

    local nameStr=${1}
    local infile=${2}
    local outfile=${3}


    printf "Setting Name to ${nameStr}\n"

    local jqCmd="jq '(.name |= \"${nameStr}\")' ${infile} > ${outfile}"

    eval $jqCmd

    if [ $? -ne 0 ]; then
        echo "Failed to replace"
        exit -1
    fi

}

if (( $# != 6 ))
then
    printf "%b" "Error. Not enough arguments.\n" >&2
    printf "%b" "usage: setName -n <name> -i <file> -o <file>\n" >&2
    exit 1
fi

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -n|-name)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        NAME=$2
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

main "${NAME}" ${INFILE} ${OUTFILE}