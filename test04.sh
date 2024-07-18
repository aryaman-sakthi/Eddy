#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#
#                                       Program: test04.sh
#                      Description: Tests the Eddy program's "MODIFIED SUBSTITUTE" command
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

# _____TEST 1: Substitute and remove all a's in aryaman sakthivel_____
cat > "$expected_output" <<EOF
rymn skthivel
EOF

echo aryaman sakthivel | python3 -s -S $eddy 's/a//g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Substitute all 1's in a line with one_____
cat > "$expected_output" <<EOF
one0
oneone
one2
one3
one4
one5
one6
one7
one8
one9
20
EOF

seq 10 20 | python3 -s -S $eddy 's/1/one/g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Substitute all even numbers [02468] with even_____
cat > "$expected_output" <<EOF
eveneven
even1
eveneven
even3
eveneven
even5
eveneven
even7
eveneven
even9
3even
EOF

seq 20 30 | python3 -s -S $eddy 's/[02468]/even/g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: Substitute all numbers with -  but only at the 5th line_____
cat > "$expected_output" <<EOF
100
101
102
103
---
105
106
107
108
109
110
EOF

seq 100 110 | python3 -s -S $eddy '5s/[0-9]/-/g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


# _____TEST 5: substitue all odd numbers with - in all lines ending with even numbers_____
cat > "$expected_output" <<EOF
-00
101
-02
103
-04
105
-06
107
-08
109
--0
EOF

seq 100 110 | python3 -s -S $eddy '/..[02468]/s/[13579]/-/g' > "$actual_output" 2>&1

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