#!/bin/bash

file=RussianPeasantMultiplication.java
MAXTIME="0.5"

if [ ! -f "$file" ]; then
    echo -e "Error: File '$file' not found.\nTest failed."
    exit 1
fi

num_right=0
total=0
line="________________________________________________________________________"
compiler=
interpreter=
language=
extension=${file##*.}
if [ "$extension" = "py" ]; then
    if [ ! -z "$PYTHON_PATH" ]; then
        interpreter=$(which python.exe)
    else
        interpreter=$(which python3.2)
    fi
    command="$interpreter $file"
    echo -e "Testing $file\n"
elif [ "$extension" = "java" ]; then
    language="java"
    command="java ${file%.java}"
    echo -n "Compiling $file..."
    javac $file
    echo -e "done\n"
elif [ "$extension" = "c" ] || [ "$extension" = "cpp" ]; then
    language="c"
    command="./${file%.*}"
    echo -n "Compiling $file..."
    results=$(make 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "\n$results"
        exit 1
    fi
    echo -e "done\n"
fi

run_test_args() {
    (( ++total ))
    echo -n "Running test $total..."
    expected=$2
    expected_return_val=$3
    local ismac=0
    date --version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
       ismac=1
    fi
    local start=0
    if (( ismac )); then
        start=$(python3 -c 'import time; print(time.time())')
    else
        start=$(date +%s.%N)
    fi
    $command $1 2>&1 | tr -d '\r' > tmp.txt
    retval=${PIPESTATUS[0]}
    local end
    if (( ismac )); then
        end=$(python3 -c 'import time; print(time.time())')
    else
        end=$(date +%s.%N)
    fi
    received=$(cat tmp.txt)
    local elapsed=$(echo "scale=3; $end - $start" | bc | awk '{printf "%.3f", $0}')
    if (( $(echo "$elapsed > $MAXTIME" | bc -l) )); then
        echo -e "failure [timeout after $MAXTIME seconds]\n"
    elif [ "$expected" != "$received" ]; then
        echo -e "failure\n\nExpected$line\n$expected\n"
        echo -e "Received$line\n$received\n"
    else
        if [ "$expected_return_val" = "$retval" ]; then
            echo "success [$elapsed seconds]"
            (( ++num_right ))
        else
            echo "failure Return value is $retval, expected $expected_return_val."
        fi
    fi
    rm -f tmp.txt input.txt
}

run_test_args "" "Usage: java RPMult <integer m> <integer n>" "1"
run_test_args "42 16 8" "Usage: java RPMult <integer m> <integer n>" "1"
run_test_args "cat 16" "Error: Invalid value 'cat' for integer m." "1"
run_test_args "42 dog" "Error: Invalid value 'dog' for integer n." "1"
run_test_args "121 2147483648" "Error: Invalid value '2147483648' for integer n." "1"
run_test_args "0 0" "0 x 0 = 0" "0"
run_test_args "1 0" "1 x 0 = 0" "0"
run_test_args "0 123" "0 x 123 = 0" "0"
run_test_args "1 1" "1 x 1 = 1" "0"
run_test_args "9 9" "9 x 9 = 81" "0"
run_test_args "1781 10" "1781 x 10 = 17810" "0"
run_test_args "148212 56431" "148212 x 56431 = 8363751372" "0"
run_test_args "134214781 58191121" "134214781 x 58191121 = 7810108561159501" "0"
run_test_args "2147483647 2147483647" "2147483647 x 2147483647 = 4611686014132420609" "0"
run_test_args "-142 23" "-142 x 23 = -3266" "0"
run_test_args "-2147483648 2" "-2147483648 x 2 = -4294967296" "0"
run_test_args "10 -2147483648" "10 x -2147483648 = -21474836480" "0"
run_test_args "-2147483647 -2147483648" "-2147483647 x -2147483648 = 4611686016279904256" "0"

echo -e "\nTotal tests run: $total"
echo -e "Number correct : $num_right"
echo -n "Percent correct: "
echo "scale=2; 100 * $num_right / $total" | bc

if [ "$language" = "java" ]; then
    echo -e -n "\nRemoving class files..."
    rm -f *.class
    echo "done"
elif [ "$language" = "c" ]; then
    echo -e -n "\nCleaning project..."
    make clean > /dev/null 2>&1
    echo "done"
fi
