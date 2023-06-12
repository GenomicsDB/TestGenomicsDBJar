#!/bin/bash

check_jar() {
  JAR=$1
  FOUND=true
  if [[ ! -f $JAR ]]; then
    echo "Could not Find $JAR"
    FOUND=false
  else
    declare -i file_size_kb
    file_size_kb=`du -k $JAR | cut -f1`
    if (( ${file_size_kb} < 10 )); then
      grep -q "404 Not Found" $JAR
      if [[ $? -eq 0 ]]; then
        echo "$JAR NOT Found"
        FOUND=false
      fi
    fi
  fi
}

MAIN_JAR=genomicsdb-${GENOMICSDB_VERSION}.jar
ALLINONE_JAR=genomicsdb-${GENOMICSDB_VERSION}-allinone.jar

check_jar $MAIN_JAR
if [[ $FOUND == false ]]; then
  exit 1
else
  check_jar $ALLINONE_JAR
  if [[ $FOUND == false ]]; then
    exit 1
  fi
fi

osname=`uname -s`
if [ "$osname" == "Linux" ]; then
	LIBRARY_SUFFIX=so
	jar xvf $MAIN_JAR libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	if [[ -f libtiledbgenomicsdb.${LIBRARY_SUFFIX} ]]; then
		ldd libtiledbgenomicsdb.${LIBRARY_SUFFIX}
		md5sum libtiledbgenomicsdb.${LIBRARY_SUFFIX}
	else
		echo "Could not find libtiledbgenomicsdb.${LIBRARY_SUFFIX}"
		exit 1
	fi
elif [ "$osname" == "Darwin" ]; then
	LIBRARY_SUFFIX=dylib
	jar xvf $MAIN_JAR libtiledbgenomicsdb.${LIBRARY_SUFFIX}
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
