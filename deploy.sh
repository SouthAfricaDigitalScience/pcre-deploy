#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add  zlib
module add bzip2
module add readline
module add cmake

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cmake .. \
 -G"Unix Makefiles" \
  -DBUILD_SHARED_LIBS=ON \
  -DPCRE2_BUILD_PCRE2_16=ON \
  -DPCRE2_BUILD_PCRE2_32=ON \
  -DZLIB_INCLUDE_DIR=${ZLIB_DIR}/include -DZLIB_LIBRARY_RELEASE=${ZLIB_DIR}/lib/libz.so \
  -DBZIP2_INCLUDE_DIR=${BZLIB_DIR}/include -DBZIP2_LIBRARY_RELEASE=${BZLIB_DIR}/lib/libbz2.so

make install
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${LIBRARIES_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/PCRE2-deploy"
setenv PCRE2_VERSION       $VERSION
setenv PCRE2_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PCRE2_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PCRE2_DIR)/include
prepend-path CFLAGS            "-I${PCRE2_DIR}/include"
prepend-path LDFLAGS           "-L${PCRE2_DIR}/lib"
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}
