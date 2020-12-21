# MashBash - Mashery Automation Scripts

These scripts allow you to export, manipulate, and import service definitions from Mashery for the purpose of automation such as CICD tasks


## Setup

You can run these scripts locally or via container

### Building Docker image

```bash
$ docker build -t mashbash:1.0 .
```

### Setup Mashery Platform API credentials

Copy the .mashdash directory to your home directory

```
cp -r .mashbash $HOME/.
```

Rename $HOME/.mashbash/env to .env and then edit setting correctly all the properties strings:

```
USERNAME=usernanem
PASSWORD=password
APIKEY=apikey
APIKEYSECRET=apikeysecret
AREA=area
TM=tm
```

Example:

```
USERNAME=mmussett
PASSWORD=a5ZqT3g1p
APIKEY=7cc8vgasy6nywruhgc995qh6
APIKEYSECRET=2q3fBBB3zz
AREA=d7a8e2d5-ee00-02eb-9885-10f2as2vvxf5
TM=eval1234.api.mashery.com
```

## Running the scripts

These scripts can be run locally or via docker containers

### Exporting Service from Mashery 

./export.sh -s service -f filename

e.g

```bash
./export.sh -s 3qfm26jub8uscy6jygqrp6pm -f export.json
```

Alternatively using container will write the export.json to shared volume hosted at ~/mashbash-shared on your host machine:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./export.sh -s 3qfm26jub8uscy6jygqrp6pm -f /app/mashbash-shared/export.json
```


### Importing Service to Mashery 

./import.sh -f filename

e.g

```bash
./import.sh -f import.json
```

Alternatively using container will read the import.json from shared volume hosted at ~/mashbash-shared on your host machine:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./import.sh -f /app/mashbash-shared/import.json
```


### Manipulating the Service Definition

#### Setting Request Path Alias

The setRequestPathAlias.sh script can be used to set the Request Path Alias on a named endpoint

./setRequestPathAlias.sh -e endpointName -r path -i infile -o outfile

e.g. Setting the Request Path Alias on endpoint named 'Account Statement v2'

```bash
./setRequestPathAlias.sh -e "Account Statement v2" -r "/prd/v2/profiles/customers/accountstatement/{aliasCode}" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setRequestPathAlias.sh -e "Account Statement v2" -r "/prd/v2/profiles/customers/accountstatement/{aliasCode}"  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```

#### Setting Traffic Manager

The setTrafficManagerDomain.sh script can be used to set the Traffic Manager Domain on a named endpoint

./setTrafficManagerDomain.sh -e endpointName -t trafficmanager -i infile -o outfile

e.g. Setting the Request Path Alias on endpoint named 'Account Statement v2'

```bash
./setTrafficManagerDomain.sh -e "Account Statement v2" -t "eval1234.api.mashery.com" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setTrafficManagerDomain.sh -e "Account Statement v2" -t "eval1234.api.mashery.com"  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```


#### Setting Public Domain Address

The setPublicDomainsAddress.sh script can be used to set the Public Domain Address on a named endpoint

./setPublicDomainsAddress.sh -e endpointName -p domain -i infile -o outfile

e.g. Setting the Request Path Alias on endpoint named 'Account Statement v2'

```bash
./setPublicDomainsAddress.sh -e "Account Statement v2" -p "eval1234.api.mashery.com" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setPublicDomainsAddress.sh -e "Account Statement v2" -p "eval1234.api.mashery.com"  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```



#### Setting System Domain Address

The setSytemDomainsAddress.sh script can be used to set the System Domain Address on a named endpoint

./setSytemDomainsAddress.sh -e endpointName -s domain -i infile -o outfile

e.g. Setting the Request Path Alias on endpoint named 'Account Statement v2'

```bash
./setSytemDomainsAddress.sh -e "Account Statement v2" -s "eval1234.api.mashery.com" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setSytemDomainsAddress.sh -e "Account Statement v2" -s "eval1234.api.mashery.com"  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```



#### Setting Service Version

The setVersion.sh script can be used to set the version on a Service

./setVersion.sh -v version -i infile -o outfile

e.g. Setting the version to 2.0

```bash
./setVersion.sh -v "2.0" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setVersion.sh -v "2.0"  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```



#### Setting Service QPS Limit Overall

The setQpsLimitOverall.sh script can be used to set the Service QPS Limit Overall

./setQpsLimitOverall.sh -q qpslimit -i infile -o outfile

e.g. Setting the QPS Limit Overall to to 20

```bash
./setQpsLimitOverall.sh -q 20 -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setQpsLimitOverall.sh -q 20  -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```


#### Setting Service Name

The setName.sh script can be used to set the Service Name

./setName.sh -n name -i infile -o outfile

e.g. Setting the Service Name to 'Boom Boom Shake da Room API'

```bash
./setName.sh -n "Boom Boom Shake da Room API" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setName.sh -n "Boom Boom Shake da Room API" -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```



#### Setting Service Description

The setDescription.sh script can be used to set the Service Description

./setDescription.sh -d description -i infile -o outfile

e.g. Setting the Service Description to 'Funky APIs rule'

```bash
./setDescription.sh -n "Funky APIs rule" -i infile.json -o outfile.json
```

Alternatively using container:

```bash
docker run --rm -v  ~/.mashbash:/app/.mashbash -v ~/mashbash-shared:/app/mashbash-shared -it mashbash:1.0  ./setDescription.sh -d "Funky APIs rule" -i /app/mashbash-shared/infile.json -o /app/mashbash-shared/outfile.json
```



