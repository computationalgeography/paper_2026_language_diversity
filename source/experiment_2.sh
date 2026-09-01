#!/bin/bash

# Check if the directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <experiment_directory>"
    exit 1
fi

# Assign the argument to a variable
directory="$1"

# Run command
PYTHONPATH=source/package/ python source/script/leco_spawn.py run \
        --max_nr_workers=$workers \
        spawn_${seed}.toml \
        -- --start_geoparquet /$directory/steps_9501_10000.geoparquet \
        --intermediate_step 10000

# Cluster command
PYTHONPATH=source/package/ python source/script/leco_spawn.py cluster \
        --max_nr_workers=$workers \
        spawn_${seed}.toml \
        -- population.gpkg --start_gpkg /$directory/population.gpkg \
        --intermediate_step 10000
