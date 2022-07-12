#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
t=out/test/elf/$testname
mkdir -p $t

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
#include <stdio.h>

__attribute__((weak)) int foo();

int main() {
  printf("%d\n", foo ? foo() : 3);
}
EOF

$CC -B. -o $t/b.so $t/a.o -shared
$CC -B. -o $t/c.so $t/a.o -shared -Wl,-z,defs

readelf --dyn-syms $t/b.so | grep -q 'WEAK   DEFAULT  UND foo'
readelf --dyn-syms $t/c.so | grep -q 'WEAK   DEFAULT  UND foo'

echo OK
