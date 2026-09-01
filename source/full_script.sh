#!/bin/bash

output_dir="path_to_your_folder"

# Set up environment
./create_environment.sh

## Experiment 1
directory_1=$output_dir/experiment_1
# Run the baseline for different seed values
seeds=(42 43 44 45 46)
for seed in seeds; do
  directory="$directory_1/seed_$seed"
  ./run_cluster_plot.sh /directory
done

# Analyze output
./analyze_baseline.sh $directory_1

# Test alternative classification configurations
alternatives=("single_linkage", "complete_linkage", "distance_0.2", "distance_0.4")
for alt in alternatives; do
  alt_dir=$output_dir/$alt
  cp $directory_1 $alt_dir
done

for seed in seeds; do
    ./classification_alternatives.sh seed
done



