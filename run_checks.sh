#!/bin/bash 
if [[ ! -f genomicsdb-${GENOMICSDB_VERSION}-allinone.jar ]]; then
  echo "Could not find genomicsdb-${GENOMICSDB_VERSION}-allinone.jar"
  exit 1
fi
if [[ ! -f genomicsdb-${GENOMICSDB_VERSION}.jar ]]; then
  echo "Could not find genomicsdb-${GENOMICSDB_VERSION}.jar"
  exit 1
fi
file_size_kb=`du -k genomicsdb-${GENOMICSDB_VERSION}-allinone.jar | cut -f1`
if [ $file_size_kb == 0 ]; then
  echo "genomicsdb-${GENOMICSDB_VERSION}-allinone.jar has no contents"
  exit 1
fi
file_size_kb=`du -k genomicsdb-${GENOMICSDB_VERSION}.jar | cut -f1`
if [ $file_size_kb == 0 ]; then
  echo "genomicsdb-${GENOMICSDB_VERSION}.jar has no contents"
  exit 1
fi
osname=`uname -s`
if [ "$osname" == "Linux" ]; then
	LIBRARY_SUFFIX=so
	jar xvf genomicsdb-${GENOMICSDB_VERSION}.jar libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	if [[ -f libtiledbgenomicsdb.${LIBRARY_SUFFIX} ]]; then
		ldd libtiledbgenomicsdb.${LIBRARY_SUFFIX}
		md5sum libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	else
		echo "Could not find libtiledbgenomicsdb.${LIBRARY_SUFFIX}"
		exit 1
	fi
elif [ "$osname" == "Darwin" ]; then
	LIBRARY_SUFFIX=dylib
	jar xvf genomicsdb-${GENOMICSDB_VERSION}.jar libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	if [[ -f libtiledbgenomicsdb.${LIBRARY_SUFFIX} ]]; then
		otool -L libtiledbgenomicsdb.${LIBRARY_SUFFIX}
		md5 -r libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	else
		echo "Could not find libtiledbgenomicsdb.${LIBRARY_SUFFIX}"
		exit 1
	fi
else
	echo "Platform $osname is not supported"
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

GENOMICSDB_TAG=${GENOMICSDB_TAG:-master}

rm -fr GenomicsDB
git clone https://github.com/GenomicsDB/GenomicsDB.git -b $GENOMICSDB_TAG

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
