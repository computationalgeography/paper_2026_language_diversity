#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <argument>"
    exit 1
fi

# Assign the arguments to variables
directory="$1"
argument="$2"

if argument is none:
    PYTHONPATH=source/package/ python environment/script/summarized_plots.py "${directory}/spawn_stats.csv"
elif argument is "baseline":
    PYTHONPATH=source/package/ python environment/script/summarized_plots.py "${directory}/base_stats.csv" --$argument
else:
    PYTHONPATH=source/package/ python environment/script/summarized_plots.py "${directory}/base_stats.csv --classification Single:/classification/single_linkage/base_stats.csv Complete:/classification/complete_linkage/base_stats.csv Distance_0.2:/classification/distance_0.2/base_stats.csv Distance_0.4:/classification/distance_0.4/base_stats.csv
