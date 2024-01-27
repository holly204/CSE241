#!/bin/bash

# Number of times to run the test
RUNS=5


# Array to store all times for standard deviation calculation
declare -a total_time

echo "Running Sysbench memory tests..."

for (( i=1; i<=RUNS; i++ ))
do
    echo "Test $i of $RUNS"
    # Run sysbench and capture the total time
    eps=$(sysbench memory --memory_block_size=1G run | grep "total time:" | awk '{print $3}')
    total_time+=($eps)

    echo "Test $i completed: $eps sec"
done

echo "$total_time"

# Function to calculate average
calculate_average() {
    sum=0
    for t in "${total_time[@]}"; do
        sum=$(echo "$sum + $t" | bc)
    done
    echo "scale=2; $sum / ${#total_time[@]}" | bc
}

# Calculating minimum, maximum, and average
min_eps=$(printf "%s\n" "${total_time[@]}" | sort -n | head -n1)
max_eps=$(printf "%s\n" "${total_time[@]}" | sort -n | tail -n1)
avg_eps=$((calculate_average))

# Calculating standard deviation
sum_sq=0
for t in "${total_time[@]}"; do
    deviation=$(echo "$t - $avg_eps" | bc)
    sum_sq=$(echo "$sum_sq + ($deviation)^2" | bc)
done
std_dev=$(echo "scale=2; sqrt($sum_sq / ${#total_time[@]})" | bc)

# Reporting results
echo "Performance Test Results for Total time:"
echo "Average: $avg_eps"
echo "Minimum: $min_eps"
echo "Maximum: $max_eps"
echo "Standard Deviation: $std_dev"




