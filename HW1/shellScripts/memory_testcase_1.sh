#!/bin/bash

# Number of tests
num_tests=5

# Array to store total time results
declare -a total_time_values

echo "Starting Sysbench memory tests..."

# Run Sysbench tests
for i in $(seq 1 $num_tests); do
    echo "Running test $i of $num_tests..."

    # Run Sysbench memory test and capture total time
    total_time=$(sysbench memory run --memory-block-size=1G | grep "total time:" | awk '{print $3}')

    # Store results in the array
    total_time_values+=($total_time)

    echo "Test $i completed: Total Time - $total_time seconds"
done

# Function to calculate average
calculate_average() {
    sum=0
    for value in "${total_time_values[@]}"; do
        sum=$(echo "$sum + $value" | bc)
    done
    echo "scale=2; $sum / ${#total_time_values[@]}" | bc
}

# Calculate average, min, max, std for total time
avg_time=$(calculate_average)
min_time=$(printf "%s\n" "${total_time_values[@]}" | sort -n | head -n1)
max_time=$(printf "%s\n" "${total_time_values[@]}" | sort -n | tail -n1)

# Calculating standard deviation
sum_sq=0
for t in "${total_time_values[@]}"; do
    deviation=$(echo "$t - $avg_time" | bc)
    sum_sq=$(echo "$sum_sq + ($deviation)^2" | bc)
done
std_dev=$(echo "scale=2; sqrt($sum_sq / ${#total_time_values[@]})" | bc)

# Output results
echo "Memory Test Total Time Results (in seconds):"
echo "Average: $avg_time"
echo "Minimum: $min_time"
echo "Maximum: $max_time"
echo "Standard Deviation: $std_dev"

