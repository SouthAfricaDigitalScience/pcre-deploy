#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add bzip2
module add readline
module  add  ncurses
module add cmake

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"

cmake ../ -G"Unix Makefiles" \
  -DCMAKE_EXE_LINKER_FLAGS_DEBUG="-L${NCURSES_DIR}/lib -L${READLINE_DIR} -lreadline -lncurses  " \
  -DCMAKE_C_FLAGS="-I${READLINE_DIR}/include  -I${NCURSES_DIR}/include " \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${READLINE_DIR}/lib -L${NCURSES_DIR}/lib -lreadline -lncurses -lhistory -ltinfo" \
  -DCMAKE_INSTALL_PREFIX=$SOFT_DIR \
  -DPCRE_BUILD_PCRE8=ON \
  -DPCRE_BUILD_PCRE16=ON \
  -DPCRE_BUILD_PCRE32=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_STATIC_LIBS=ON \
  -DBZIP2_INCLUDE_DIR=${BZLIB_DIR}/include \
  -DBZIP2_LIBRARY_RELEASE=${BZLIB_DIR}/lib/libbz2.so \
  -DNCURSES_LIBRARY=${NCURSES_DIR}/lib/libncurses.so \
  -DREADLINE_INCLUDE_DIR="${READLINE_DIR}/include" \
  -DREADLINE_LIBRARY="${READLINE_DIR}/lib/libreadline.so ${NCURSES_DIR}/lib/ncurses.so" \
  -DPCRE_SUPPORT_LIBREADLINE=OFF \
  -DPCRE_SUPPORT_LIBBZ2=ON \
  -DPCRE_SUPPORT_UTF=ON

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

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/PCRE-deploy"
setenv PCRE_VERSION       $VERSION
setenv PCRE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PCRE_DIR)/lib
prepend-path PATH              $::env(PCRE_DIR)/bin
prepend-path GCC_INCLUDE_DIR   $::env(PCRE_DIR)/include
prepend-path CFLAGS            "-I${PCRE_DIR}/include"
prepend-path LDFLAGS           "-L${PCRE_DIR}/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

module avail ${NAME}
module add ${NAME}/${VERSION}
