# pcre2-deploy

Build, test and deploy scripts for Perl Compatible Regular Expression


# Versions

We build

  * 10.23

# Dependencies

This project depends on

   * zlib
   * bzip2
   * readline
   * cmake

# Configuration

```
cmake .. \
 -G"Unix Makefiles" \
  -DBUILD_SHARED_LIBS=ON \
  -DPCRE2_BUILD_PCRE2_16=ON \
  -DPCRE2_BUILD_PCRE2_32=ON \
  -DZLIB_INCLUDE_DIR=${LIBZ_DIR}/include -DZLIB_LIBRARY_RELEASE=${ZLIB_DIR}/lib/libz.so \
  -DBZIP2_INCLUDE_DIR=${BZlIB_DIR}/include -DBZIP2_LIBRARY_RELEASE=${BZLIB_DIR}/lib/libbz2.so
```

# Citing
