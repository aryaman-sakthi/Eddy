#!/bin/dash


# ================================================================================================>
#                                  COMP2041 ASSIGNMENT 2 : Eddy
#                                       Program: test08.sh
#
#                                        Subset 1 : Test08
#               Description: Tests Eddy program by reading eddy commands from file
#                            Tests Eddy program by reading input lines from file
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

# _____TEST 1: Quit after the 5th line_____
cat > "$expected_output" <<EOF
1
2
3
4
EOF

#Add command[s] to the file
echo '4q' > commandsFile
seq 1 5 | python3 -s -S $eddy -f commandsFile > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-1 Passed"


# _____TEST 2: Delete the Last line_____
cat > "$expected_output" <<EOF
1
2
3
4
EOF

#Add command[s] to the file
echo '$d' > commandsFile
seq 1 5 | python3 -s -S $eddy -f commandsFile  > "$actual_output" 2>&1

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

#Add command[s] to the file
echo '4d;4q' > commandsFile
seq 1 10| python3 -s -S $eddy -f commandsFile > "$actual_output" 2>&1

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

#Add command[s] to the file
echo '4q' > commandsFile
echo '4d' >> commandsFile
seq 1 10| python3 -s -S $eddy -f commandsFile > "$actual_output" 2>&1

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

#Add command[s] to the file
echo '3p' > commandsFile
echo 's/3/*/' >> commandsFile
seq 1 5| python3 -s -S $eddy -f commandsFile > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-5 Passed"


# _____TEST 6: Substitute the 3rd line to three and Quit after getting 4_____
cat > "$expected_output" <<EOF
1
2
three
4
EOF

#Add input lines to a file
seq 1 5 > five.txt |

python3 -s -S $eddy '3s/.*/three/;4q' five.txt > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-6 Passed"


# _____TEST 7: Delete odd numbers and Quit after 10 lines_____
cat > "$expected_output" <<EOF
2
4
6
8
EOF

#Add input lines to a file
seq 1 5 > first.txt
seq 6 10 > second.txt |

python3 -s -S $eddy '/[13579]/d;10q' first.txt second.txt> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-7 Passed"


# _____TEST 8: Delete even numbers and Quit after reaching 15_____
cat > "$expected_output" <<EOF
1
3
5
7
9
11
13
15
EOF

#Add input lines to a file
seq 1 10 > first.txt
seq 11 20 > second.txt

#Add command[s] into a file
echo '/[02468]/d' > commandsFile
echo '/15/q' >> commandsFile |

python3 -s -S $eddy -f commandsFile first.txt second.txt> "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "${RED}Failed test \n\nYour Output:"
    cat "$actual_output"
    exit 1
fi

#Return Test passed if outputs match
echo "${GREEN} Test-8 Passed"

#Return Test Passed if no test fails
echo "${GREEN} \nAll Tests passed"
exit 0