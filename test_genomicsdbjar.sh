#!/bin/bash

export GENOMICSDB_VERSION=1.0.0-20190225.231734-14
export CLASSPATH=genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar:.
export MAVEN_REPOSITORY=https://oss.sonatype.org/content/repositories/snapshots/org/genomicsdb/genomicsdb/1.0.0-SNAPSHOT/

curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar
curl -O ${MAVEN_REPOSITORY}/genomicsdb-${GENOMICSDB_VERSION}.jar

bash -x ./run_checks.sh

rm -fr GenomicsDB
git clone https://github.com/GenomicsDB/GenomicsDB.git

CLASSPATH=`pwd`/genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar:.

echo "Compiling Test Classes..."
rm -fr *.class
javac -d . GenomicsDB/example/java/*.java
echo "Done"
echo

echo "Starting ETL..."
java TestGenomicsDBImporterWithMergedVCFHeader -L 1:1-100000 -w /tmp/ws -A test0 GenomicsDB/tests/inputs/vcfs/t0.vcf.gz GenomicsDB/tests/inputs/vcfs/t1.vcf.gz GenomicsDB/tests/inputs/vcfs/t2.vcf.gz --vidmap-output /tmp/vid_pb.json --callset-output /tmp/callset_pb.json
echo "Done"
echo

echo "Starting query..."
java TestGenomicsDB --pass_through_query_json --query query.json
echo "Done"
echo


