#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
t=out/test/elf/$MACHINE/$testname
mkdir -p $t

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
void foo() {}
void bar();
int main() { bar(); }
EOF

cat <<EOF | $CC -B. -shared -fPIC -o $t/b.so -xc -
void foo() {}
void bar() {}
EOF

$CC -B. -o $t/exe1 $t/a.o $t/b.so
nm -g $t/exe1 | grep -q foo

cat <<'EOF' > $t/c.ver
{ local: *; global: xyz; };
EOF

$CC -B. -o $t/exe2 $t/a.o $t/b.so -Wl,--version-script=$t/c.ver
nm -g $t/exe2 > $t/log2
! grep -q foo $t/log2 || false

cat <<'EOF' > $t/d.ver
{ local: *; };
EOF

$CC -B. -o $t/exe3 $t/a.o $t/b.so -Wl,--version-script=$t/d.ver
nm -g $t/exe3 > $t/log3
! grep -q foo $t/log3 || false

echo OK
