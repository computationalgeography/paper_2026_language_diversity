#!/bin/bash

# Check if the directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <experiment_directory>"
    exit 1
fi

# Assign the argument to a variable
experiment_dir="$1"

PYTHONPATH=source/package/ python environment/script/leco_summarized.py "${experiment_dir}/" --baseline
PYTHONPATH=source/package/ python environment/script/summarized_plots.py "${experiment_dir}/base_stats.csv" --baseline
