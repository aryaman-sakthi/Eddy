#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#
#                                       Program: test00.sh
#                      Description: Tests the Eddy program's "QUIT" command
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

# _____TEST 1: Quit after the 3rd line_____
cat > "$expected_output" <<EOF
1
2
3
EOF

seq 1 5 | python3 -s -S $eddy '3q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Quit after matching 5 in input lines_____
cat > "$expected_output" <<EOF
1
2
3
4
5
EOF

seq 1 5 | python3 -s -S $eddy '/5/q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Quit after matching /1.1/ in input lines_____
cat > "$expected_output" <<EOF
100
101
EOF

seq 100 120 | python3 -s -S $eddy '/1.1/q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: Quit after first line (without any regex or index)_____
cat > "$expected_output" <<EOF
1
EOF

seq 1 5 | python3 -s -S $eddy 'q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


# _____TEST 5: Quit after 5 lines in $ yes_____
cat > "$expected_output" <<EOF
y
y
y
y
y
EOF

yes | head | python3 -s -S $eddy '5q' > "$actual_output" 2>&1

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