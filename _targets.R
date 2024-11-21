library(targets)
library(tarchetypes)
library(clustermq)

### Running on HPC
## Settings for clustermq
options(
  clustermq.scheduler = "slurm",
  clustermq.template = "./cmq.tmpl" # if using your own template
)

## Settings for clustermq template when running clustermq on HPC
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

# Loads all R scripts in ./R/ directory.
# Here, all packages are loaded from the ./R/packages.R file
# The calc_forward_vel function is loaded from the ./R/calc_forward_vel.R file
tar_source()

tar_plan(
  # Load the required paths.
  input_folders <- list(
    ForestClim_12 = "E:/Output/SDM_test/belgium/tiles/ForestClim_12/",
    ForestClim_15 = "E:/Output/SDM_test/belgium/tiles/ForestClim_15/",
    ForestClim_05 = "E:/Output/SDM_test/belgium/tiles/ForestClim_05/",
    ForestClim_06 = "E:/Output/SDM_test/belgium/tiles/ForestClim_06/",
    cec = "E:/Output/SDM_test/belgium/tiles/cec/",
    clay = "E:/Output/SDM_test/belgium/tiles/clay/"
  ),
  mdl_paths <- list.files("E:/SDMs/Stef_SDMs/Models/", full.names = T),

  # Create predictor lists.
  tar_target(pred_ls, predictorls(input_folders)),

  # Make future species distributions.
  tar_target(futureSDM_predict, futureSDM(mdl_paths, pred_ls))
)
