#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#                                       Program: test07.sh
#
#                                        Subset 1 : Test07
#                     Description: Tests Eddy program with multiple commands
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

# _____TEST 1: Quit after the 5th line Delete lines with 1 and 2_____
cat > "$expected_output" <<EOF
3
4
5
EOF

seq 1 10| python3 -s -S $eddy '5q;/[12]/d' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Delete lines with 1 and 2 Quit after the 5th line_____
cat > "$expected_output" <<EOF
3
4
5
EOF

seq 1 10| python3 -s -S $eddy '/[12]/d;5q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-2 Passed"


# _____TEST 3: Delete the line where Quit is called (eg: line 4)_____
cat > "$expected_output" <<EOF
1
2
3
5
6
7
8
9
10
EOF

seq 1 10| python3 -s -S $eddy '4d;4q' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-3 Passed"


# _____TEST 4: Quit on the line where Delete is called (eg: line 4)_____
cat > "$expected_output" <<EOF
1
2
3
4
EOF

seq 1 10| python3 -s -S $eddy '4q;4d' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-4 Passed"


# _____TEST 5: Print a line and Substitute it_____
cat > "$expected_output" <<EOF
1
2
3
*
4
5
EOF

seq 1 5 | python3 -s -S $eddy '3p;s/3/*/' > "$actual_output" 2>&1

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