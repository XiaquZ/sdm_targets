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
      job_name = "auto-sdms",
      per_cpu_mem = "4000mb",
      n_tasks = 1,
      per_task_cpus = 36,
      walltime = "15:00:00"
    ))
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
tar_plan(
  # Load the required paths.
  input_folders <- list(
    ForestClim_12 = "/lustre1/scratch/348/vsc34871/output/tiles/ForestClim_12/",
    ForestClim_15 = "/lustre1/scratch/348/vsc34871/output/tiles/ForestClim_15/",
    ForestClim_05 = "/lustre1/scratch/348/vsc34871/output/tiles/ForestClim_05/",
    ForestClim_06 = "/lustre1/scratch/348/vsc34871/output/tiles/ForestClim_06/",
    cec = "/lustre1/scratch/348/vsc34871/output/tiles/cec/",
    clay = "/lustre1/scratch/348/vsc34871/output/tiles/clay/"
  ),
  mdl_paths <- list.files("/lustre1/scratch/348/vsc34871/input/Models/", full.names = T),

  # Create predictor lists.
  tar_target(pred_ls, predictorls(input_folders)),

  # Make future species distributions.
  tar_target(futureSDM_predict, futureSDM(mdl_paths, pred_ls))
)
