#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

cd leco
source lecoenv/bin/activate

seeds=(42 43 44 45 46)
dir_path=/your_path_to_output/tracing_ld

# Test alternative classification configurations
alternatives=("single_linkage" "complete_linkage" "distance_0.2" "distance_0.4")

# Make a copy of the output of the baseline run and store in folders specific for the alternative classifications
for alt in "${alternatives[@]}"; do
  alt_dir="/${dir_path}/classification/${alt}/"
  mkdir -p "${alt_dir}"

  # Copy only .geoparquet, .toml, and meta_data.csv files from experiment_1,
  # preserving directory structure, skipping everything else
  rsync -a \
    --include='*/' \
    --include='*.geoparquet' \
    --include='*.toml' \
    --include='meta_data.csv' \
    --exclude='*' \
    --prune-empty-dirs \
    "/${dir_path}/experiment_1/" "${alt_dir}"
done

# Execute the different classification approaches for five seeds
for seed in "${seeds[@]}"; do
    # Cluster with different configurations
    PYTHONPATH=source/package/ python source/script/leco_model.py cluster --linkage single /${dir_path}/classification/single_linkage/seed_${seed}/configuration.toml /${dir_path}/classification/single_linkage/seed_${seed}/ population.gpkg
    PYTHONPATH=source/package/ python source/script/leco_model.py cluster --linkage complete /${dir_path}/classification/complete_linkage/seed_${seed}/configuration.toml /${dir_path}/classification/complete_linkage/seed_${seed}/ population.gpkg
    PYTHONPATH=source/package/ python source/script/leco_model.py cluster --distance 0.2 /${dir_path}/classification/distance_0.2/seed_${seed}/configuration.toml /${dir_path}/classification/distance_0.2/seed_${seed}/ population.gpkg
    PYTHONPATH=source/package/ python source/script/leco_model.py cluster --distance 0.4 /${dir_path}/classification/distance_0.4/seed_${seed}/configuration.toml /${dir_path}/classification/distance_0.4/seed_${seed}/ population.gpkg

    # Plot with different configurations
    PYTHONPATH=source/package/ python source/script/leco_model.py plot /${dir_path}/classification/single_linkage/seed_${seed}/configuration.toml /${dir_path}/classification/single_linkage/seed_${seed}/ popul>
    PYTHONPATH=source/package/ python source/script/leco_model.py plot /${dir_path}/classification/complete_linkage/seed_${seed}/configuration.toml /${dir_path}/classification/complete_linkage/seed_${seed}/ p>
    PYTHONPATH=source/package/ python source/script/leco_model.py plot /${dir_path}/classification/distance_0.2/seed_${seed}/configuration.toml /${dir_path}/classification/distance_0.2/seed_${seed}/ populatio>
    PYTHONPATH=source/package/ python source/script/leco_model.py plot /${dir_path}/classification/distance_0.4/seed_${seed}/configuration.toml /${dir_path}/classification/distance_0.4/seed_${seed}/ populatio>

done

# Analyze the different classification settings individually
for alt in "${alternatives[@]}"; do
  alt_dir="/${dir_path}"/classification/"${alt}"
  PYTHONPATH=source/package/ python environment/script/leco_summarized.py "${alt_dir}" --baseline
done

# Compare the four alternative settings with the default
PYTHONPATH=source/package/ python environment/script/summarized_plots.py /${dir_path}/experiment_1/base_stats.csv --classification Single:/${dir_path}/classification/single_linkage/base_stats.csv Complete:/${dir_path}/classification/complete_linkage/base_stats.csv Distance_0.2:/${dir_path}/classification/distance_0.2/base_stats.csv Distance_0.4:/${dir_path}/classification/distance_0.4/base_stats.csv
