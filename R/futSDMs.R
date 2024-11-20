predictorls <- function(input_folders) {
  # Create a list to store predictors for each tile separately
  predls <- list()
  
  # Iterate through tiles (assumes tiles are numbered from 1 to 9)
  for (i in 1:9) {
    # Initialize an empty list to store predictors for this tile
    tile_preds <- list()
    # Define predictor keywords
    predictors <- c("bio5", "bio6", "bio12", "bio15", "cec", "clay")
    
    # Iterate through predictors and read corresponding rasters
    for (predictor in predictors) {
      # Find the folder for the predictor
      folder <- grep(predictor, input_folders, value = TRUE)
      
      # Construct the file path
      file_path <- file.path(folder, paste0(predictor, "_", i, ".tif"))
      
      # Check if the file exists
      if (file.exists(file_path)) {
        # Read the raster and assign a name
        raster <- rast(file_path)
        names(raster) <- predictor
        tile_preds[[predictor]] <- raster
      } else {
        warning(paste("File not found:", file_path))
      }
    }
    
    # Combine rasters for this tile
    if (length(tile_preds) > 0) {
      predls[[i]] <- rast(tile_preds)
    } else {
      warning(paste("No predictors found for tile", i))
    }
  }
  
  # Return the list of predictors for all tiles
  return(predls)
} 


futureSDM <- function(mdl_paths, predls) {
  for (i in seq_along(mdl_paths)) {
    # Load one of the SDMs
    species_name <- gsub(".RData", "", basename(mdl_paths[[i]]))
    print(paste0("Start selecting lowest AIC model for: ", species_name))

    # Load model object
    mdl <- load(mdl_paths[[i]])
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
    for (j in seq_along(predls)) {
      print(paste0("Start predicting the future SDM for: ", species_name, "_tile_", j))
      
      if (length(min_index) == 1) {
        futsd <- predictMaxNet(mdl_select, predls[[j]], type = "logistic")
        futsd <- futsd * 100
        
        writeRaster(futsd,
          filename = paste0("E:/Output/SDM_test/belgium/out/", species_name, "_tile_", j),
          overwrite = TRUE)
      } else {
        for (k in seq_along(min_index)) {
          mdl_select <- mdl@models[[min_index[[k]]]]
          futsd <- predictMaxNet(mdl_select, predls[[j]], type = "logistic")
          futsd <- futsd * 100
          
          writeRaster(futsd,
            filename = paste0(
              "E:/Output/SDM_test/belgium/out/",
              species_name, "_tile_", j, "_model", k),
            overwrite = TRUE)
        }
      }
    }
  }
}
