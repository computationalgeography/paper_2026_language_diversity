#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <argument>"
    exit 1
fi

# Assign the arguments to variables
directory="$1"
argument="$2"

if argument is none:
    PYTHONPATH=source/package/ python environment/script/leco_summarized.py "${directory}/"
else:
    PYTHONPATH=source/package/ python environment/script/leco_summarized.py "${directory}/" --$argument
