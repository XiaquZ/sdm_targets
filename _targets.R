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
tar_source("R/packages.R")

tar_plan(
input_folders <- list(
  bio12 = "E:/Output/SDM_test/belgium/tiles/bio12/",
  bio15 = "E:/Output/SDM_test/belgium/tiles/bio15/",
  bio5 = "E:/Output/SDM_test/belgium/tiles/BIO5/",
  bio6 = "E:/Output/SDM_test/belgium/tiles/BIO6/",
  cec = "E:/Output/SDM_test/belgium/tiles/cec/",
  clay = "E:/Output/SDM_test/belgium/tiles/clay/"
),
mdl_paths <- list.files("E:/SDMs/Stef_SDMs/Models/", full.names = T),

  tar_target(predictor_list, predictorls(input_folders)),
  tar_target(futureSDM_predict,
  futureSDM(mdl_paths, predls),
  )
)
