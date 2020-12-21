#!/bin/bash


tempFile1=$(mktemp)
tempFile2=$(mktemp)


./export.sh -s 3qfm26jub8uscy6jygqrp6pm -f export.json

cp export.json ${tempFile1}

./setRequestPathAlias.sh -e "Account Statement v2" -r "/prd/v2/profiles/customers/accountstatement/{aliasCode}" -i ${tempFile1} -o ${tempFile2}
./setRequestPathAlias.sh -e "Spend Request v2" -r "/prd/v2/profiles/customers/spendrequest/{transactionId}" -i ${tempFile2} -o ${tempFile1}
./setRequestPathAlias.sh -e "Customer Information v2" -r "/prd/v2/profiles/customers/customerinformation/{memberAlias}" -i ${tempFile1} -o ${tempFile2}
./setRequestPathAlias.sh -e "Member Status v2" -r "/prd/v2/profiles/customers/memberstatus/{cardnumber}" -i ${tempFile2} -o ${tempFile1} 


./setTrafficManagerDomain.sh -e "Account Statement v2" -t "emealocal1.api.mashery.com" -i ${tempFile1} -o ${tempFile2}
./setTrafficManagerDomain.sh -e "Spend Request v2" -t "emealocal1.api.mashery.com" -i ${tempFile2} -o ${tempFile1}
./setTrafficManagerDomain.sh -e "Customer Information v2" -t "emealocal1.api.mashery.com" -i ${tempFile1} -o ${tempFile2}
./setTrafficManagerDomain.sh -e "Member Status v2" -t "emealocal1.api.mashery.com" -i ${tempFile2} -o ${tempFile1} 

./setPublicDomainsAddress.sh -e "Account Statement v2" -p "emealocal1.api.mashery.com" -i ${tempFile1} -o ${tempFile2}
./setPublicDomainsAddress.sh -e "Spend Request v2" -p "emealocal1.api.mashery.com" -i ${tempFile2} -o ${tempFile1}
./setPublicDomainsAddress.sh -e "Customer Information v2" -p "emealocal1.api.mashery.com" -i ${tempFile1} -o ${tempFile2}
./setPublicDomainsAddress.sh -e "Member Status v2" -p "emealocal1.api.mashery.com" -i ${tempFile2} -o ${tempFile1} 

./setSystemDomainsAddress.sh -e "Account Statement v2" -s "eu-west-1.integration.cloud.tibcoapps.com" -i ${tempFile1} -o ${tempFile2}
./setSystemDomainsAddress.sh -e "Spend Request v2" -s "eu-west-1.integration.cloud.tibcoapps.com" -i ${tempFile2} -o ${tempFile1}
./setSystemDomainsAddress.sh -e "Customer Information v2" -s "eu-west-1.integration.cloud.tibcoapps.com" -i ${tempFile1} -o ${tempFile2}
./setSystemDomainsAddress.sh -e "Member Status v2" -s "eu-west-1.integration.cloud.tibcoapps.com" -i ${tempFile2} -o ${tempFile1} 


./setVersion.sh -v "2.0" -i ${tempFile1} -o ${tempFile2}

./setQpsLimitOverall.sh -q 10 -i ${tempFile2} -o ${tempFile1}

./setName.sh -n "Boom Boom Shake da Room API" -i ${tempFile1} -o ${tempFile2}


cp ${tempFile2} import.json

./import.sh -f import.json