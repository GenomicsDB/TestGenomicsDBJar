#!/bin/bash

####
# Set the following variables as necessary
####
IS_SNAPSHOT=true

rm -fr /tmp/ws

if [ ${IS_SNAPSHOT} == true ]; then
		export GENOMICSDB_VERSION=1.4.0-20210112.235702-1
		export GENOMICSB_REPOSITORY_VERSION=1.4.0-SNAPSHOT
		export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/snapshots/org/genomicsdb/genomicsdb/${GENOMICSB_REPOSITORY_VERSION}
else
	export GENOMICSDB_VERSION=1.4.0
	#export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/staging/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
  export MAVEN_REPOSITORY=https://repo1.maven.org/maven2/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
fi

####
# Leave rest of the script alone
####
echo "Using MAVEN_REPOSITORY=$MAVEN_REPOSITORY"

curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}-allinone.jar
curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}.jar

export CLASSPATH=genomicsdb-${GENOMICSDB_VERSION}-allinone.jar:.

./run_checks.sh
if [[ $? -ne 0 ]]; then
    echo "run_checks FAILED"
    exit 1
fi

echo
echo "Basic GenomicsDBVersion check..."
javac GenomicsDBGetVersion.java && java GenomicsDBGetVersion
if [[ $? -ne 0 ]]; then
    echo "GenomicsDBGetVersion FAILED"
    exit 1
fi
echo "Done"
echo

rm -fr GenomicsDB
git clone https://github.com/GenomicsDB/GenomicsDB.git

echo "Compiling Test Classes..."
rm -fr *.class
javac -d . GenomicsDB/example/java/*.java &&
echo "Done" &&
echo &&

echo "Starting ETL..." &&
java TestGenomicsDBImporterWithMergedVCFHeader -L 1:1-100000 -w /tmp/ws -A test0 GenomicsDB/tests/inputs/vcfs/t0.vcf.gz GenomicsDB/tests/inputs/vcfs/t1.vcf.gz GenomicsDB/tests/inputs/vcfs/t2.vcf.gz --vidmap-output /tmp/vid_pb.json --callset-output /tmp/callset_pb.json &&
echo "ETL SUCCESS" &&
echo &&

echo "Starting query..." &&
java TestGenomicsDB --query -l loader.json query.json &&
rm -fr /tmp/ws &&
echo "Query SUCCESS" &&
echo

if [[ $? -ne 0 ]]; then
    echo "TestGenomicsDBJAR FAILED"
    exit 1
fi




