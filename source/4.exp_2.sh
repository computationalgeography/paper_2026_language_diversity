#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12

cd leco
source lecoenv/bin/activate

seeds=(42 43 44 45 46)
dir_path=/your_path_to_output/tracing_ld
workers=10

for seed in "${seeds[@]}"; do
    echo "Processing seed ${seed}"

    # Run command
    PYTHONPATH=source/package/ python source/script/leco_spawn.py run \
        --max_nr_workers=$SLURM_CPUS_PER_TASK \
        /${dir_path}/config/experiment_2/spawn_${seed}.toml \
        -- --start_geoparquet /${dir_path}/experiment_1/seed_${seed}/steps_9501_10000.geoparquet \
        --intermediate_step 10000

    # Cluster command
    PYTHONPATH=source/package/ python source/script/leco_spawn.py cluster \
        --max_nr_workers=$SLURM_CPUS_PER_TASK \
        /${dir_path}/config/experiment_2/spawn_${seed}.toml \
        -- population.gpkg --start_gpkg /${dir_path}/experiment_1/seed_${seed}/population.gpkg \
        --intermediate_step 10000
done

# Analyze outcomes
PYTHONPATH=source/package/ python environment/script/leco_summarized.py /${dir_path}/experiment_2/
PYTHONPATH=source/package/ python environment/script/summarized_plots.py /${dir_path}/experiment_2/spawn_stats.csv