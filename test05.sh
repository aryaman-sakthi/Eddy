#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#
#                                       Program: test05.sh
#                      Description: Tests ALL the Eddy program's commands (Subset 0)
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

# _____TEST 1: Quit after reaching a line with the number 1 occuring thrice_____
cat > "$expected_output" <<EOF
100
101
102
103
104
105
106
107
108
109
110
111
EOF

seq 100 115 | python3 -s -S $eddy '/[1-9]{3}/q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Print ONLY (-n) all even numbers_____
cat > "$expected_output" <<EOF
2
4
6
8
10
12
14
16
18
20
EOF

seq 1 20 | python3 -s -S $eddy -n '/[02468]/p' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Delete all lines from line_2 to line_5_____
cat > "$expected_output" <<EOF
1
6
7
8
9
10
EOF

seq 1 10 | python3 -s -S $eddy '2,5d' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: Delete all lines containing numbers between 2 to 5_____
cat > "$expected_output" <<EOF
100
101
106
107
108
109
110
111
EOF

seq 100 115 | python3 -s -S $eddy '/2/,/5/d' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


#Return Test Passed if no test fails
echo "${GREEN} \nAll Tests passed"
exit 0