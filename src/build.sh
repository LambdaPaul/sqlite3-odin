#!/usr/bin/env bash
set -eu

pushd "$(dirname "$0")"

ARCH="$(uname -m)"
OS="$(uname -o)"
LIB_A="libsqlite3_${ARCH}"

if clang -v &> /dev/null; then
    CC=clang
elif gcfc -v &> /dev/null; then
    CC=gcc 
else
    echo "Missing 'gcc'/ 'clang'"
    exit 1
fi

if [ $OS == "Darwin" ]; then
    libtool -V &> /dev/null || { echo "Missing 'libtool'"; exit 2 }
fi

$CC -c -O3 -Qn "./sqlite3.c" -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_UTF16 -DSQLITE_OMIT_TEST_CONTROL

if [ $OS == "Darwin" ]; then 
    libtool -static "sqlite3.o" -o "../lib/${LIB_A}.a"
fi

rm *.o &> /dev/null
rm *.tmp &> /dev/null

popd

