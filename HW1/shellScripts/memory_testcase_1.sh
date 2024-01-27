#!/bin/bash

# Number of tests
num_tests=5

# Array to hold the test results
declare -a results

echo "Starting Sysbench Memory tests..."

# Running Sysbench tests
for i in $(seq 1 $num_tests); do
    echo "Test $i of $num_tests..."
    result=$(sysbench memory run --memory_block_size=1M | grep "total time:" | awk '{print $3}')
    results+=($result)
    echo "Test $i completed: $result seconds"
done

# Function to calculate average
calculate_average() {
    sum=0
    for t in "${results[@]}"; do
        sum=$(echo "$sum + $t" | bc)
    done
    echo "scale=2; $sum / ${#results[@]}" | bc
}

# Calculating minimum, maximum, and average
min=$(printf "%s\n" "${results[@]}" | sort -n | head -n1)
max=$(printf "%s\n" "${results[@]}" | sort -n | tail -n1)
avg=$(calculate_average)

# Calculating standard deviation
sum_sq=0
for t in "${results[@]}"; do
    sum_sq=$(echo "$sum_sq + ($t - $avg)^2" | bc)
done
std_dev=$(echo "scale=2; sqrt($sum_sq / ${#results[@]})" | bc)

# Reporting results
echo "Performance Test Results:"
echo "Average Time: $avg seconds"
echo "Minimum Time: $min seconds"
echo "Maximum Time: $max seconds"
echo "Standard Deviation: $std_dev seconds"




