#!/bin/bash

####
# Set the following variables as necessary
####
IS_SNAPSHOT=false

if [ ${IS_SNAPSHOT} == true ]; then
		export GENOMICSDB_VERSION=1.2.0-20191127.233149-2
		export GENOMICSB_REPOSITORY_VERSION=1.2.0-SNAPSHOT
		export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/snapshots/org/genomicsdb/genomicsdb/${GENOMICSB_REPOSITORY_VERSION}
else
	export GENOMICSDB_VERSION=1.1.1
	#export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/staging/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
  export MAVEN_REPOSITORY=https://repo1.maven.org/maven2/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}
fi

####
# Leave the rest of the script alone
####

export CLASSPATH=genomicsdb-${GENOMICSDB_VERSION}-allinone.jar:.

curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}-allinone.jar
curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}.jar

./run_checks.sh
if [[ $? -ne 0 ]]; then
    echo "run_checks FAILED"
    exit 1
fi

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
echo "Query SUCCESS" &&
echo

if [[ $? -ne 0 ]]; then
    echo "TestGenomicsDBJAR FAILED"
    exit 1
fi




