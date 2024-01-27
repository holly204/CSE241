#!/bin/bash

# Number of runs for the test
num_runs=5

# Arrays to hold the read and write throughput values
read_values=()
write_values=()

# Running the tests
for i in $(seq 1 $num_runs); do
    echo "Running test $i of $num_runs..."

    # Run the sysbench fileio test and store the output
    sysbench fileio --file-total-size=2G --file-test-mode=rndrw prepare
    output=$(sysbench fileio --file-total-size=2G --file-test-mode=rndrw  run)
    sysbench fileio --file-total-size=2G --file-test-mode=rndrw cleanup

    # Extract read and write throughput
    read_throughput=$(echo "$output" | grep "read, MiB/s:" | awk '{print $3}')
    write_throughput=$(echo "$output" | grep "written, MiB/s:" | awk '{print $3}')

    # Append the throughput values to their respective arrays
    read_values+=($read_throughput)
    write_values+=($write_throughput)
done

# Function to calculate min, max, avg, and standard deviation
calculate_stats() {
    local -a values=("$@")
    local length=${#values[@]}
    local sum=0 max=0 min=0 sd=0

    # Calculate sum, min, and max
    for v in "${values[@]}"; do
        sum=$(echo "$sum + $v" | bc)
        if [[ $v == ${values[0]} ]] || [[ $(echo "$v < $min" | bc) -eq 1 ]]; then min=$v; fi
        if [[ $v == ${values[0]} ]] || [[ $(echo "$v > $max" | bc) -eq 1 ]]; then max=$v; fi
    done

    # Calculate average
    local avg=$(echo "scale=2; $sum / $length" | bc)

    # Calculate standard deviation
    for v in "${values[@]}"; do
        sd=$(echo "$sd + ($v - $avg)^2" | bc)
    done
    sd=$(echo "scale=2; sqrt($sd / $length)" | bc)

    echo "Min: $min Max: $max Avg: $avg SD: $sd"
}

# Calculate and print the stats for read and write values
echo "Read Throughput (MiB/s):"
calculate_stats "${read_values[@]}"

echo "Write Throughput (MiB/s):"
calculate_stats "${write_values[@]}"


