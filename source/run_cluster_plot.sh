#!/bin/bash

# Check if the directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <experiment_directory>"
    exit 1
fi

# Assign the argument to a variable
experiment_dir="$1"

# Run the commands with the passed directory
PYTHONPATH=source/package/ python source/script/leco_model.py run configuration_exp1.toml "${experiment_dir}"
PYTHONPATH=source/package/ python source/script/leco_model.py cluster "${experiment_dir}/configuration.toml" "${experiment_dir}/" population.gpkg
PYTHONPATH=source/package/ python source/script/leco_model.py plot "${experiment_dir}/configuration.toml" "${experiment_dir}/" population.gpkg
