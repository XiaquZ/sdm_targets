predict_futSDM <- function(input_folders, mdl_paths) {

  # Iterate through tiles (assumes tiles are numbered from 1 to 9)
  for (i in 1:14) {
    # Initialize an empty list to store predictors for this tile
    # Define predictor keywords
    predictors <- c(
      "Micro_BIO5_EU_CHELSAbased_2000.2020", "Micro_BIO6_EU_CHELSAbased_2000.2020",
      "CHELSA_bio12_EU_2000.2019", "CHELSA_bio15_EU_2000.2019", "cec", "clay",
      "Slope", "Elevation", "TWI", "phh2o_0_30_WeightedMean"
    )

    # Get file paths of all predictors
    files <- c()
    # Iterate through predictors and read corresponding rasters
    for (predictor in predictors) {
      # Find the folder for the predictor
      folder <- grep(predictor, input_folders, value = TRUE)

     # Construct the file path
      files <- c(files, paste0(folder, predictor, "_", i, ".tif"))
    }
        # --- NEW: Check if all files exist for this tile ---
    if (!all(file.exists(files))) {
      message(paste0("Skipping tile ", i, " because one or more predictor files are missing."))
      next
    }

    stack_preds <- vrt(files, options="-separate")
    names(stack_preds) <- c(
      "Micro_BIO5_EU_CHELSAbased_2000.2020", "Micro_BIO6_EU_CHELSAbased_2000.2020",
      "CHELSA_bio12_EU_2000.2019", "CHELSA_bio15_EU_2000.2019", "cec", "clay",
      "Slope", "Elevation", "TWI", "phh2o_0_30_WeightedMean"
    )
    print(stack_preds)

      # Load one of the SDMs
      species_name <- gsub("_ENMeval_swd.RData", "", basename(mdl_paths))
      print(paste0("Start selecting lowest AIC model for: ", species_name))

      # Load model object
      mdl <- load(mdl_paths)
      mdl <- e.swd
      
      # Select the best SDM based on delta AIC
      res <- eval.results(mdl)
      min_index <- which(res$delta.AICc == min(res$delta.AICc))
      

      if (length(min_index) == 1) {
        mdl_select <- mdl@models[[min_index]]
      } else {
        warning(paste0(species_name, " has more than one selected model"))
        mdl_select <- mdl@models[[min_index]]
      }

      # Predict the future distribution for each raster tile
      print(paste0(
        "Start predicting the future SDM for: ",
        species_name, "_tile_", i
      ))

      if (length(min_index) == 1) {
        futsd <- ENMeval::maxnet.predictRaster(
        mod = mdl_select,
        envs = stack_preds,
        pred.type = "cloglog",
        doClamp = TRUE,
      ) 
        futsd <- futsd * 100
        futsd <- round(futsd, digits = 1)
        print(futsd)
        writeRaster(futsd,
          filename = paste0(
            "/lustre1/scratch/348/vsc34871/SDM_fut/results/",
            species_name, "_tile_", i, ".tif"
          ),
          overwrite = TRUE
        )
      } else {
        for (k in seq_along(min_index)) {
          mdl_select <- mdl@models[[min_index[[k]]]]
          futsd <- ENMeval::maxnet.predictRaster(
          mod = mdl_select,
          envs = stack_preds,
          pred.type = "cloglog",
          doClamp = TRUE,
        )
          futsd <- futsd * 100
          futsd <- round(futsd, digits = 1)
        print(futsd)

          writeRaster(futsd,
            filename = paste0(
              "/lustre1/scratch/348/vsc34871/SDM_fut/results/",
              species_name, "_tile_", i, "_model", k, ".tif"
            ),
            overwrite = TRUE
          )
        }
      }
    
  }
}
