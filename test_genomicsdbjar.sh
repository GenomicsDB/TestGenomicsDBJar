#!/bin/bash

####
# Set the following variables as necessary
####
IS_SNAPSHOT=false

rm -fr /tmp/ws

if [ ${IS_SNAPSHOT} == true ]; then
		export GENOMICSDB_VERSION=1.4.3-20211216.233338-1	
		export GENOMICSB_REPOSITORY_VERSION=1.4.3-SNAPSHOT
		export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/snapshots/org/genomicsdb/genomicsdb/${GENOMICSB_REPOSITORY_VERSION}
else
	export GENOMICSDB_VERSION=1.4.3
	#export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/staging/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
  export MAVEN_REPOSITORY=https://repo1.maven.org/maven2/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
fi

####
# Leave rest of the script alone
####
echo "Using MAVEN_REPOSITORY=$MAVEN_REPOSITORY"

curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}-allinone.jar
curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}.jar

GENOMICSDB_TAG=v$GENOMICSDB_VERSION ./run_checks.sh
if [[ $? -ne 0 ]]; then
    echo "run_checks FAILED"
    exit 1
fi


