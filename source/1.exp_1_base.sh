#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

cd leco
source lecoenv/bin/activate

seeds=(42 43 44 45 46)
dir_path=/your_path_to_output/tracing_ld

# Loop over each seed
for seed in "${seeds[@]}"; do
    echo "Processing seed ${seed}"

    # Run command
    PYTHONPATH=source/package/ python source/script/leco_model.py run /${dir_path}/config/experiment_1/seed_${seed}.toml /${dir_path}/experiment_1/seed_${seed}/

    # Cluster command
    PYTHONPATH=source/package/ python source/script/leco_model.py cluster /${dir_path}/experiment_1/seed_${seed}/configuration.toml /${dir_path}/experiment_1/seed_${seed}/ population.gpkg

    # Plot command
    PYTHONPATH=source/package/ python source/script/leco_model.py plot /${dir_path}/experiment_1/seed_${seed}/configuration.toml /${dir_path}/experiment_1/seed_${seed}/ population.gpkg
done