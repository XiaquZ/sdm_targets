predict_futSDM <- function(input_folders, mdl_paths) {

  # Iterate through tiles (assumes tiles are numbered from 1 to 9)
  for (i in 1:99) {
    # Initialize an empty list to store predictors for this tile
    # Define predictor keywords
    predictors <- c(
      "ForestClim_05", "ForestClim_06",
      "ForestClim_12", "ForestClim_15", "cec", "clay"
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
    stack_preds <- vrt(files, options="-separate")
    names(stack_preds) <- c(
      "ForestClim_05", "ForestClim_06",
      "ForestClim_12", "ForestClim_15", "cec", "clay"
    )
    print(stack_preds)

      # Load one of the SDMs
      species_name <- gsub(".RData", "", basename(mdl_paths))
      print(paste0("Start selecting lowest AIC model for: ", species_name))

      # Load model object
      mdl <- load(mdl_paths)
      mdl <- e.mx_rp.f
      
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
        futsd <- predictMaxNet(mdl_select, stack_preds, type = "logistic")
        futsd <- futsd * 100

        writeRaster(futsd,
          filename = paste0(
            "/lustre1/scratch/348/vsc34871/output/futSDM_out/",
            species_name, "_tile_", i, ".tif"
          ),
          overwrite = TRUE
        )
      } else {
        for (k in seq_along(min_index)) {
          mdl_select <- mdl@models[[min_index[[k]]]]
          futsd <- predictMaxNet(mdl_select, stack_preds, type = "logistic")
          futsd <- futsd * 100

          writeRaster(futsd,
            filename = paste0(
              "/lustre1/scratch/348/vsc34871/output/futSDM_out/",
              species_name, "_tile_", i, "_model", k, ".tif"
            ),
            overwrite = TRUE
          )
        }
      }
    
  }
}
