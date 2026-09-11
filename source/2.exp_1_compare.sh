#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

cd leco
source lecoenv/bin/activate

dir_path=/your_path_to_output/tracing_ld

PYTHONPATH=source/package/ python environment/script/leco_summarized.py /${dir_path}/experiment_1/ --baseline
PYTHONPATH=source/package/ python environment/script/summarized_plots.py /${dir_path}/experiment_1/base_stats.csv --baseline