#!/usr/bin/env bash
set -eu

OS="$(uname -o)"
LIB_A="libsqlite3"

pushd "$(dirname "$0")"


if clang -v &> /dev/null; then
    CC=clang
elif gcfc -v &> /dev/null; then
    CC=gcc 
else
    echo "Missing 'gcc'/ 'clang'"
    exit 1
fi

if [ $OS == "Darwin" ]; then
    libtool -V &> /dev/null || ( echo "Missing 'libtool'"; exit 2 )
    $CC -c -O3 -Qn -arch x86_64 -o "x86_64.o" "./sqlite3.c" -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_UTF16 -DSQLITE_OMIT_TEST_CONTROL
    libtool -static "x86_64.o" -o "../lib/${LIB_A}_x64.a"
    $CC -c -O3 -Qn -arch arm64 -o "arm64.o" "./sqlite3.c" -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_UTF16 -DSQLITE_OMIT_TEST_CONTROL
    libtool -static "arm64.o" -o "../lib/${LIB_A}_arm64.a"
fi


rm *.o &> /dev/null
rm *.tmp &> /dev/null

popd

