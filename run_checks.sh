#!/bin/bash 
osname=`uname -s`
jar xf genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar libtiledbgenomicsdb.so
jar xf genomicsdb-${GENOMICSDB_VERSION}-jar-with-dependencies.jar libtiledbgenomicsdb.dylib
if [ "$osname" == "Darwin" ];
then
    LIBRARY_SUFFIX=dylib
    otool -L libtiledbgenomicsdb.${LIBRARY_SUFFIX}
    md5 -r libtiledbgenomicsdb.${LIBRARY_SUFFIX}
else
    LIBRARY_SUFFIX=so
    ldd libtiledbgenomicsdb.${LIBRARY_SUFFIX}
    md5sum libtiledbgenomicsdb.${LIBRARY_SUFFIX}
fi
#rm -f libtiledbgenomicsdb.${LIBRARY_SUFFIX}
#jar xf genomicsdb-${GENOMICSDB_VERSION}.jar libtiledbgenomicsdb.${LIBRARY_SUFFIX}
#md5sum libtiledbgenomicsdb.${LIBRARY_SUFFIX}
