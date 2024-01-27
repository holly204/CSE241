#!/bin/bash

# Memory block size from the first argument
memory_block_size=1G

# Number of tests
num_tests=5

# Array to store total time results
total_time_values=()

echo "Starting Sysbench memory tests with block size $memory_block_size..."

# Run Sysbench tests
for i in $(seq 1 $num_tests); do
    echo "Running test $i of $num_tests..."

    # Run Sysbench memory test and capture total time
    total_time=$(sysbench memory --memory-block-size=$memory_block_size run | grep "total time:" | awk '{print $3}')

    # Store results in the array
    total_time_values+=("$total_time")

    echo "Test $i completed: Total Time - $total_time seconds"
done

# Function to calculate average
calculate_average() {
    local sum=0
    for value in "${total_time_values[@]}"; do
        sum=$(echo "$sum + $value" | bc -l)
    done
    local avg=$(echo "$sum / ${#total_time_values[@]}" | bc -l)
    printf "%.2f\n" "$avg"
}

# Function to calculate standard deviation
calculate_std() {
    local avg=$(calculate_average)
    local sum_sq=0
    local n=${#total_time_values[@]}

    for value in "${total_time_values[@]}"; do
        sum_sq=$(echo "$sum_sq + ($value - $avg)^2" | bc -l)
    done

    local std=$(echo "sqrt($sum_sq / $n)" | bc -l)
    printf "%.2f\n" "$std"
}

# Calculate average, min, max, and standard deviation for total time
avg_time=$(calculate_average)
std_time=$(calculate_std)
min_time=$(printf "%s\n" "${total_time_values[@]}" | sort -n | head -n1)
max_time=$(printf "%s\n" "${total_time_values[@]}" | sort -n | tail -n1)

# Output results
echo "Memory Test Total Time Results (in seconds):"
echo "Average: $avg_time"
echo "Minimum: $min_time"
echo "Maximum: $max_time"
echo "Standard Deviation: $std_time"


