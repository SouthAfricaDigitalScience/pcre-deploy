#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add bzip2
module add readline
module add cmake

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

#make test

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       PCRE2_VERSION       $VERSION
setenv       PCRE2_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PCRE2_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PCRE2_DIR)/include
prepend-path CFLAGS            "-I${PCRE2_DIR}/include"
prepend-path LDFLAGS           "-L${PCRE2_DIR}/lib"
MODULE_FILE
) > modules/$VERSION

mkdir -vp ${LIBRARIES}/${NAME}
cp -v modules/$VERSION ${LIBRARIES}/${NAME}

module avail ${NAME}

module add ${NAME}/${VERSION}
