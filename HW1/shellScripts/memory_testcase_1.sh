#!/bin/bash

# Number of times to run the test
RUNS=5

# Sysbench parameters (adjust as needed)
MEMORY_BLOCK_SIZE=1G

# Array to store all times for standard deviation calculation
declare -a events_per_sec

echo "Running Sysbench Memory tests..."

for (( i=1; i<=RUNS; i++ ))
do
    echo "Test $i of $RUNS"
    # Run sysbench and capture the total time
    eps=$(sysbench memory --memory_block_size=$MEMORY_BLOCK_SIZE run | grep "total time:" | awk '{gsub(/s/, ""); print $3}')
    events_per_sec+=($eps)

    echo "Test $i completed: $eps sec"
done


# Function to calculate average
calculate_average() {
    sum=0
    for t in "${events_per_sec[@]}"; do
        sum=$(echo "$sum + $t" | bc)
    done
    echo "scale=2; $sum / ${#events_per_sec[@]}" | bc
}

# Calculating minimum, maximum, and average
min_eps=$(printf "%s\n" "${events_per_sec[@]}" | sort -n | head -n1)
max_eps=$(printf "%s\n" "${events_per_sec[@]}" | sort -n | tail -n1)
avg_eps=$(calculate_average)

# Calculating standard deviation
sum_sq=0
for t in "${events_per_sec[@]}"; do
    deviation=$(echo "$t - $avg_eps" | bc)
    sum_sq=$(echo "$sum_sq + ($deviation)^2" | bc)
done
std_dev=$(echo "scale=6; sqrt($sum_sq / ${#events_per_sec[@]})" | bc)

# Reporting results
echo "Performance Test Results for Total Time:"
echo "Average: $avg_eps"
echo "Minimum: $min_eps"
echo "Maximum: $max_eps"
echo "Standard Deviation: $std_dev"



