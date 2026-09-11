# Scripts and commands

This file contains the scripts and commands that were used to generate the results of the paper: Tracing language diversity through agent-based modeling.

## Setting up leco environment

### Move to leco directory

Put the path to the place where the `leco` repository is stored. This command is called in every bash script. A submodule of `leco`  can be find within this repository.

```bash
cd leco
```

### Create and initialize a virtual environment

Upon first use, the leco virtual environment can be created as follows, which is also find in the script `source/0.create_environment.sh`. Some dependencies may not be supported by the latest version of Python. Python 3.12 works in any case.

```bash
python -m venv lecoenv
source lecoenv/bin/activate
pip install --upgrade pip
pip install -r environment/configuration/requirements.txt
pre-commit install
```



## Experiment 1

The configuration file, `config/experiment_1/seed_42.toml`, below was used as the baseline configuration for experiment 1.

```toml
[initialization]
agents = 1000
steps = 10000
seed = 42
write_interval = 500
nr_start_languages = 4

[space]
shape = [1000, 1000]

[initialization_subset_area]
present = false
x_extent = [400,600]
y_extent = [400,600]

[barrier]
present = false
x_extent = [250, 450]
y_extent = [0, 1000]
impermeability = 0.6

[movement]
speed = 10

[language]
meanings = 100
forms = 120
mutation_rate = 0.00005

[population_dynamics]
death_rate = 0.0
birth_rate = 0.0
logistic_growth = false
carrying_capacity = 1000
end_growth_time = 50

[interaction]
radius = 50
partner_proportion = 0.4
diffusion_rate = 0.14
similarity_preference = 0.6
```

The `leco` model was run on the configuration file above. All three commands were run with default settings. This was replicated for five different seed values, 42, 43, 44, 45, and 46 for which the different configuration files are found in `config/experiment_1/`. The script below corresponds to `source/1.exp_1_base.sh`.

```bash
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
```

Run, cluster and plot for a single seed takes around 4 to 7 hours, so if there is the change to run in parallel, I would recommend doing that.

To compare the five replicates, the outputs were analyzed with `source/1.exp_1_compare.sh`;

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

cd leco
source lecoenv/bin/activate

dir_path=/your_path_to_output/tracing_ld

PYTHONPATH=source/package/ python environment/script/leco_summarized.py /${dir_path}/experiment_1/ --baseline
PYTHONPATH=source/package/ python environment/script/summarized_plots.py /${dir_path}/experiment_1/base_stats.csv --baseline
```

To test for robustness to alternative classification configurations, we ran the same configuration file for the same five seed values for different settings in the cluster command. Below the commands for single linkage, complete linkage, a distance threshold of 0.2 and a distance threshold of 0.4 are shown. These results were saved in separate folders. The script corresponds to `source/3.exp_1_classifications.sh`.

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

cd leco
source lecoenv/bin/activate

seeds=(42,43,44,45,46)
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

```



## Experiment 2

In the second experiment, we took the final time step of the first experiment as the starting point. For the `leco` configuration, `config/experiment_2/seed_42.toml`, we used the following;

```toml
[initialization]
agents = 1000
steps = 4000
seed = 42
write_interval = 500
nr_start_languages = 4

[space]
shape = [1000, 1000]

[initialization_subset_area]
present = false
x_extent = [400,600]
y_extent = [400,600]

[barrier]
present = false
x_extent = [250, 450]
y_extent = [0, 1000]
impermeability = 0.6

[movement]
speed = 10

[language]
meanings = 100
forms = 120
mutation_rate = 0.00005

[population_dynamics]
death_rate = 0.0
birth_rate = 0.0
logistic_growth = false
carrying_capacity = 1000
end_growth_time = 50

[interaction]
radius = 50
partner_proportion = 0.4
diffusion_rate = 0.14
similarity_preference = 0.6
```

and for the spawn, `spawn_42.toml`;

```toml
# Regular Leco model configuration file to tweak
configuration_file = "/${dir_path}/config/experiment_2/seed_42.toml"

# Template to use for generating output directory pathnames. All variable parameters must be mentioned.
directory_pattern = "/${dir_path}/experiment_2/speed_{speed}/mutation_rate_{mutation_rate}/radius_{radius}/diffusion_rate_{diffusion_rate}/similarity_preference_{similarity_preference}/seed_{seed}"

[sensitivity.run]
# Section with settings for performing a sensitivity analysis
method = "ofat" # One factor at a time

[sensitivity.run.initialization]
seed.range = [42, 43, 1]

[sensitivity.run.movement]
speed.range = [0, 32.5, 2.5]

[sensitivity.run.language]
mutation_rate.range = [0.0, 0.0001625, 0.0000125]

[sensitivity.run.interaction]
radius.range = [0.0, 162.5, 12.5]
diffusion_rate.range = [0.0, 0.455, 0.035]
similarity_preference.range = [-1.0, 1.2, 0.2]
```

Every seed has an individual seed_$seed.toml and spawn_$seed.toml file, stored in `/config/experiment_2/`, as it requires a separate starting point, by changing the seed.range. These starting points are the outcomes of experiment 1. To run the second experiment for the five seeds, all starting from their individual starting point, the `source/4.exp_2.sh` bash script was used. The run and cluster command are called via the spawn function, that can execute runs in parallel. When running on a cluster, you can change the `cpus-per-task` to the number of cpu's preferred.

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12

cd leco
source lecoenv/bin/activate

seeds=(42,43,44,45,46)
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

```

