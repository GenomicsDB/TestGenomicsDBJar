#!/bin/bash

export GENOMICSDB_VERSION=1.1.1
export CLASSPATH=genomicsdb-${GENOMICSDB_VERSION}-allinone.jar:.
export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/staging/org/genomicsdb/genomicsdb/${GENOMICSDB_VERSION}

curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}-allinone.jar
curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}.jar

bash -x ./run_checks.sh

rm -fr GenomicsDB
git clone https://github.com/GenomicsDB/GenomicsDB.git

echo "Compiling Test Classes..."
rm -fr *.class
javac -d . GenomicsDB/example/java/*.java &&
echo "Done" &&
echo &&

echo "Starting ETL..." &&
java TestGenomicsDBImporterWithMergedVCFHeader -L 1:1-100000 -w /tmp/ws -A test0 GenomicsDB/tests/inputs/vcfs/t0.vcf.gz GenomicsDB/tests/inputs/vcfs/t1.vcf.gz GenomicsDB/tests/inputs/vcfs/t2.vcf.gz --vidmap-output /tmp/vid_pb.json --callset-output /tmp/callset_pb.json &&
echo "Done" &&
echo &&

echo "Starting query..." &&
java TestGenomicsDB --query -l loader.json query.json &&
echo "Done" &&
echo

if [[ $? -ne 0 ]]; then
        echo "TestGenomicsDBJAR FAILED"
        exit 1
fi




