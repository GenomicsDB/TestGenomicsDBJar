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
  echo "genomicsdb-${GENOMICSDB_VERSION}-allinone.jar has no contensts"
  exit 1
fi
file_size_kb=`du -k genomicsdb-${GENOMICSDB_VERSION}.jar | cut -f1`
if [ $file_size_kb == 0 ]; then
  echo "genomicsdb-${GENOMICSDB_VERSION}.jar has no contensts"
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
