#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#
#                                       Program: test03.sh
#                      Description: Tests the Eddy program's "SUBSTITUTE" command
#
#                                by: Aryaman Sakthivel (z5455785)
# ================================================================================================>


# add the current directory to the PATH 
# so scripts can still be executed from it after we cd

PATH="$PATH:$(pwd)"

#path to the directory where eddy is stored
directory=$(realpath eddy.py | sed 's/\/eddy.py//g')

#Green Color for output
GREEN='\033[0;32m'
#Red Color for output
RED='\033[0;31m'

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.

expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT
 
# Variable to call eddy.py easily
eddy="$directory/eddy.py"

# _____TEST 1: Substitute line matching 3 with abc_____
cat > "$expected_output" <<EOF
1
2
abc
4
5
EOF

seq 1 5 | python3 -s -S $eddy 's/3/abc/' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Substitute lines containing 1 with one_____
cat > "$expected_output" <<EOF
one
2
3
4
5
6
7
8
9
one0
one1
one2
EOF

seq 1 12 | python3 -s -S $eddy 's/1/one/' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Substitute even numbers [02468] with even_____
cat > "$expected_output" <<EOF
1
even
3
even
5
even
7
even
9
1even
EOF

seq 1 10 | python3 -s -S $eddy 's/[02468]/even/' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: Substitute and remove a in aryaman sakthivel_____
cat > "$expected_output" <<EOF
ryaman sakthivel
EOF

echo aryaman sakthivel | python3 -s -S $eddy 's/a//' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


# _____TEST 5: substitue last 2 digits of all numbers ending with odd numbers with _odd_____
cat > "$expected_output" <<EOF
100
1_odd
102
1_odd
104
1_odd
106
1_odd
108
1_odd
EOF

seq 100 109 | python3 -s -S $eddy 's/.[13579]/_odd/' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-5 Passed"

#Return Test Passed if no test fails
echo "${GREEN} \nAll Tests passed"
exit 0