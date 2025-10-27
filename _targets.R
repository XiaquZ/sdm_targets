# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline
# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(clustermq)

### Running on HPC
## Settings for clustermq
options(
  clustermq.scheduler = "slurm",
  clustermq.template = "./cmq.tmpl" # if using your own template
)

# Set target options:
tar_option_set(
  resources = tar_resources(
    clustermq = tar_resources_clustermq(template = list(
      job_name = "future-sdms",
      per_cpu_mem = "53500mb",
      n_tasks = 2,
      per_task_cpus = 14,
      walltime = "120:00:00"
    ))
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
tar_plan(
  # Load the required paths
    input_folders = list(
    cec = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/cec/",
    CHELSA_bio12_EU_2000.2019 = "/lustre1/scratch/348/vsc34871/SDM_fut/pred_tiles/CHELSA_bio12_EU_2000.2019/",
    CHELSA_bio15_EU_2000.2019 = "/lustre1/scratch/348/vsc34871/SDM_fut/pred_tiles/CHELSA_bio15_EU_2000.2019/",
    clay = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/clay/",
    Elevation = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/Elevation/",
    Micro_BIO5_EU_CHELSAbased_2000.2020 = "/lustre1/scratch/348/vsc34871/SDM_fut/pred_tiles/Micro_BIO5_EU_CHELSAbased_2000.2020/",
    Micro_BIO6_EU_CHELSAbased_2000.2020 = "/lustre1/scratch/348/vsc34871/SDM_fut/pred_tiles/Micro_BIO6_EU_CHELSAbased_2000.2020/",
    Slope = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/Slope/",
    TWI = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/TWI/",
    phh2o_0_30_WeightedMean = "/lustre1/scratch/348/vsc34871/SDM_current/pred_bigtiles/phh2o_0_30_WeightedMean/"
  ),
  # Note that although the input folders named bio5, bio6, bio12, and bio15 in period 2000-2000,
  # they actually contain future climate data for 2071-2100 under the SSP3-7.0 scenario.
  tar_target(mdl_paths,
    list.files(
    "/lustre1/scratch/348/vsc34871/SDM_fut/Models03/",
    full.names = TRUE
  )),
  # Make future species distributions
  tar_target(futureSDMs,
   predict_futSDM(input_folders, mdl_paths),
   pattern = map(mdl_paths)
   )
)
