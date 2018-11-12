#!/bin/bash 
osname=`uname -s`
if [ "$osname" == "Linux" ]; then
	LIBRARY_SUFFIX=so
	jar xf genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	if [[ -f libtiledbgenomicsdb.${LIBRARY_SUFFIX} ]]; then
		ldd libtiledbgenomicsdb.${LIBRARY_SUFFIX}
		md5sum libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	else
		echo "Could not find libtiledbgenomicsdb.${LIBRARY_SUFFIX}"
		exit 1
	fi
elif [ "$osname" == "Darwin" ]; then
	LIBRARY_SUFFIX=dylib
	jar xf genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar libtiledbgenomicsdb.{LIBRARY_SUFFIX}
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
