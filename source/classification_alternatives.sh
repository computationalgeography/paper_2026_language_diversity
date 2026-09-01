#!/bin/bash

# Check if the directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <seed_number>"
    exit 1
fi

# Assign the argument to a variable
seed_number="$1"

PYTHONPATH=source/package/ python source/script/leco_model.py cluster --linkage single /classification/single_linkage/seed_$seed_number/configuration.toml /classification/single_linkage/seed_$seed_number/ population.gpkg
PYTHONPATH=source/package/ python source/script/leco_model.py cluster --linkage complete /classification/complete_linkage/seed_$seed_number/configuration.toml /classification/complete_linkage/seed_$seed_number/ population.gpkg
PYTHONPATH=source/package/ python source/script/leco_model.py cluster --distance 0.2 /classification/distance_0.2/seed_$seed_number/configuration.toml /classification/distance_0.2/seed_$seed_number/ population.gpkg
PYTHONPATH=source/package/ python source/script/leco_model.py cluster --distance 0.4 /classification/distance_0.4/seed_$seed_number/configuration.toml /classification/distance_0.4/seed_$seed_number/ population.gpkg
