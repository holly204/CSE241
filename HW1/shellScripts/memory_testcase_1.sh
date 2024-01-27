#!/bin/bash

# Number of tests
num_tests=5

# Array to store total time for each test
declare -a total_times

echo "Starting Sysbench memory tests..."

# Running the Sysbench memory tests
for i in $(seq 1 $num_tests); do
    echo "Running test $i of $num_tests..."

    # Running Sysbench memory test and capturing the total time
    time=$(sysbench memory run --memory-block-size=1M --memory-total-size=1G | grep "total time:" | awk '{print $3}')
    total_times+=($time)

    echo "Test $i: Total Time - $time seconds"
done

# Function to calculate average
calculate_average() {
    sum=0
    for t in "${total_times[@]}"; do
        sum=$(echo "$sum + $t" | bc)
    done
    echo "scale=2; $sum / ${#total_times[@]}" | bc
}

# Function to calculate standard deviation
calculate_std() {
    avg=$(calculate_average)
    sum_sq=0
    for t in "${total_times[@]}"; do
        sum_sq=$(echo "$sum_sq + ($t - $avg)^2" | bc)
    done
    echo "scale=2; sqrt($sum_sq / ${#total_times[@]})" | bc
}

# Calculating average, minimum, maximum, and standard deviation
avg=$(calculate_average)
min=$(printf "%s\n" "${total_times[@]}" | sort -n | head -n1)
max=$(printf "%s\n" "${total_times[@]}" | sort -n | tail -n1)
std=$(calculate_std)

# Outputting the results
echo "Sysbench Memory Test Results:"
echo "Average Time: $avg seconds"
echo "Minimum Time: $min seconds"
echo "Maximum Time: $max seconds"
echo "Standard Deviation: $std seconds"


