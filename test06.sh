#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#                                       Program: test06.sh
#
#                                        Subset 1 : Test06
#             Description: Tests Eddy programs substitute with different delimiters 
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

# _____TEST 1: Substitute 1 and 2 with - {delimiter used X}_____
cat > "$expected_output" <<EOF
-
-
3
4
5
EOF

seq 1 5| python3 -s -S $eddy 'sX[12]X-X' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Substitute 1 and 2 with - {delimiter used ?}_____
cat > "$expected_output" <<EOF
-
-
3
4
5
EOF

seq 1 5| python3 -s -S $eddy 's?[12]?-?' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Substitue all 1's in a line {delimiter used -}_____
cat > "$expected_output" <<EOF
X0
XX
X2
X3
X4
X5
X6
X7
X8
X9
20
EOF

seq 10 20 | python3 -s -S $eddy 's-[1]-X-g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: substitue all numbers to X {delimiter used ?}_____
cat > "$expected_output" <<EOF
XX
XX
XX
XX
XX
XXX
XXX
XXX
XXX
XXX
XXX
EOF

seq 95 105 | python3 -s -S $eddy 's?[0-9]?X?g' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


# _____TEST 5: substitute all odd numbers to / {delimiter used 0}_____
cat > "$expected_output" <<EOF
/0
//
/2
//
/4
//
/6
//
/8
//
20
EOF

seq 10 20 | python3 -s -S $eddy 's0[13579]0/0g' > "$actual_output" 2>&1

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