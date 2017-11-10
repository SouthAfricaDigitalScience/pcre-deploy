#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add  zlib
module add bzip2
module add readline
module  add  ncurses
module add cmake

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cmake ../ -G"Unix Makefiles" \
  -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-L${NCURSES_DIR}/lib -L${READLINE_DIR} -lreadline -lncurses  " \
  -DCMAKE_C_FLAGS="-I${READLINE_DIR}/include  -I${NCURSES_DIR}/include " \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${READLINE_DIR}/lib -L${NCURSES_DIR}/lib -lreadline -lncurses -lhistory -ltinfo" \
  -DCMAKE_INSTALL_PREFIX=$SOFT_DIR \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_STATIC_LIBS=ON \
  -DPCRE2_BUILD_PCRE2_16=ON \
  -DPCRE2_BUILD_PCRE2_32=ON \
  -DBZIP2_INCLUDE_DIR=${BZLIB_DIR}/include \
  -DBZIP2_LIBRARY_RELEASE=${BZLIB_DIR}/lib/libbz2.so \
  -DNCURSES_LIBRARY=${NCURSES_DIR}/lib/libncurses.so \
  -DNCURSES_INCLUDE_DIR=${NCURSES_DIR}/include \
  -DREADLINE_INCLUDE_DIR="${READLINE_DIR}/include" \
  -DREADLINE_LIBRARY="${READLINE_DIR}/lib/libreadline.so ${NCURSES_DIR}/lib/ncurses.so" \
  -DPCRE2_SUPPORT_LIBREADLINE=OFF \
  -DPCRE2_SUPPORT_LIBBZ2=ON
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
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
prepend-path PATH              $::env(PCRE2_DIR)/bin
prepend-path GCC_INCLUDE_DIR   $::env(PCRE2_DIR)/include
prepend-path CFLAGS            "-I${PCRE2_DIR}/include"
prepend-path LDFLAGS           "-L${PCRE2_DIR}/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

module avail ${NAME}
module add ${NAME}/${VERSION}
