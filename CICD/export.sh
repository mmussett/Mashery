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
    printf "Authenticating with Mashery\n"

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

exportServiceToStdout () {

    local token="$1" 
    local service="$2" 

    local tempFile=$(mktemp)

    local cmd="curl -s --location --request GET 'https://api.mashery.com/v3/rest/services/3qfm26jub8uscy6jygqrp6pm?fields=cache,created,crossdomainPolicy,description,editorHandle,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCall,endpoints.forceGzipOfBackendCallid,endpoints.forwardedHeaders,endpoints.gzipPassthroughSupportEnabled,endpoints.headersToExcludeFromIncomingCall,endpoints.highSecurity,endpoints.hostPassthroughIncludedInBackendCallHeader,endpoints.inboundSslRequired,endpoints.jsonpCallbackParameter,endpoints.jsonpCallbackParameterValue,endpoints.methods,endpoints.methods.name,endpoints.methods.responseFilters,endpoints.methods.responseFilters.created,endpoints.methods.responseFilters.id,endpoints.methods.responseFilters.jsonFilterFields,endpoints.methods.responseFilters.name,endpoints.methods.responseFilters.notes,endpoints.methods.responseFilters.updated,endpoints.methods.responseFilters.xmlFilterFields,endpoints.methods.sampleJsonResponse,endpoints.methods.sampleXmlResponse,endpoints.name,endpoints.numberOfHttpRedirectsToFollow,endpoints.oauthGrantTypes,endpoints.outboundRequestTargetPath,endpoints.outboundRequestTargetQueryParameters,endpoints.outboundTransportProtocol,endpoints.processor,endpoints.publicDomains,endpoints.requestAuthenticationType,endpoints.requestPathAlias,endpoints.requestProtocol,endpoints.returnedHeaders,endpoints.scheduledMaintenanceEvent,endpoints.scheduledMaintenanceEvent.endDateTime,endpoints.scheduledMaintenanceEvent.endpoints,endpoints.scheduledMaintenanceEvent.id,endpoints.scheduledMaintenanceEvent.name,endpoints.scheduledMaintenanceEvent.startDateTime,endpoints.stringsToTrimFromApiKey,endpoints.supportedHttpMethods,endpoints.systemDomainAuthentication,endpoints.systemDomainAuthentication.certificate,endpoints.systemDomainAuthentication.password,endpoints.systemDomainAuthentication.type,endpoints.systemDomainAuthentication.username,endpoints.systemDomains,endpoints.trafficManagerDomain,endpoints.useSystemDomainCredentials,errorSets,errorSets.errorMessages,errorSets.jsonp,errorSets.jsonpType,errorSets.name,errorSets.type,id,name,qpsLimitOverall,revisionNumber,rfc3986Encode,robotsPolicy,roles,roles.action,roles.created,roles.id,roles.name,roles.updates,securityProfile,updated,version&limit=100&offset=0' \
--header 'Authorization: Bearer ${token}'"

    eval $cmd > ${tempFile}

    if [ $? -ne 0 ]; then
        echo "Failed to extract Service definition from Mashery"
        exit -1
    fi

    cat ${tempFile}

}

exportServiceToFile () {

    local token="$1" 
    local service="$2" 
    local outFile="$3"


    printf "Exporting Service definition to file '${outFile}'\n"
  

    local tempFile=$(mktemp)

    local cmd="curl -s --location --request GET 'https://api.mashery.com/v3/rest/services/3qfm26jub8uscy6jygqrp6pm?fields=cache,created,crossdomainPolicy,description,editorHandle,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCall,endpoints.forceGzipOfBackendCallid,endpoints.forwardedHeaders,endpoints.gzipPassthroughSupportEnabled,endpoints.headersToExcludeFromIncomingCall,endpoints.highSecurity,endpoints.hostPassthroughIncludedInBackendCallHeader,endpoints.inboundSslRequired,endpoints.jsonpCallbackParameter,endpoints.jsonpCallbackParameterValue,endpoints.methods,endpoints.methods.name,endpoints.methods.responseFilters,endpoints.methods.responseFilters.created,endpoints.methods.responseFilters.id,endpoints.methods.responseFilters.jsonFilterFields,endpoints.methods.responseFilters.name,endpoints.methods.responseFilters.notes,endpoints.methods.responseFilters.updated,endpoints.methods.responseFilters.xmlFilterFields,endpoints.methods.sampleJsonResponse,endpoints.methods.sampleXmlResponse,endpoints.name,endpoints.numberOfHttpRedirectsToFollow,endpoints.oauthGrantTypes,endpoints.outboundRequestTargetPath,endpoints.outboundRequestTargetQueryParameters,endpoints.outboundTransportProtocol,endpoints.processor,endpoints.publicDomains,endpoints.requestAuthenticationType,endpoints.requestPathAlias,endpoints.requestProtocol,endpoints.returnedHeaders,endpoints.scheduledMaintenanceEvent,endpoints.scheduledMaintenanceEvent.endDateTime,endpoints.scheduledMaintenanceEvent.endpoints,endpoints.scheduledMaintenanceEvent.id,endpoints.scheduledMaintenanceEvent.name,endpoints.scheduledMaintenanceEvent.startDateTime,endpoints.stringsToTrimFromApiKey,endpoints.supportedHttpMethods,endpoints.systemDomainAuthentication,endpoints.systemDomainAuthentication.certificate,endpoints.systemDomainAuthentication.password,endpoints.systemDomainAuthentication.type,endpoints.systemDomainAuthentication.username,endpoints.systemDomains,endpoints.trafficManagerDomain,endpoints.useSystemDomainCredentials,errorSets,errorSets.errorMessages,errorSets.jsonp,errorSets.jsonpType,errorSets.name,errorSets.type,id,name,qpsLimitOverall,revisionNumber,rfc3986Encode,robotsPolicy,roles,roles.action,roles.created,roles.id,roles.name,roles.updates,securityProfile,updated,version&limit=100&offset=0' \
--header 'Authorization: Bearer ${token}'"

    eval $cmd > ${tempFile}

    if [ $? -ne 0 ]; then
        echo "Failed to extract Service definition from Mashery"
        exit -1
    fi

    mv ${tempFile} ${outFile}

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
    printf "%b" "usage: export -s <service> [-f <file>]\n" >&2
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
  exportServiceToFile $MASHERY_ACCESS_TOKEN $SERVICE $FILENAME
else
  exportServiceToStdout $MASHERY_ACCESS_TOKEN $SERVICE 
fi

