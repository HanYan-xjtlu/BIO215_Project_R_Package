# R/main.R
# ============================================================
# BIO215 Capstone Project - R Package Source Code
# ============================================================

#' Predict Protein Classification
#'
#' @title Predict Protein Class from Physicochemical Properties
#' @description This function predicts the functional classification of proteins
#' (Hydrolase, Transferase, or Oxidoreductase) based on input physicochemical features.
#' It utilizes a pre-trained Random Forest model embedded within the package to ensure
#' robust and reproducible predictions suitable for bioinformatics workflows.
#'
#' @param new_data A data.frame containing the biochemical feature columns.
#' The data frame must include the following numeric variables:
#' \itemize{
#'   \item \code{structureMolecularWeight}: Molecular weight of the protein structure (Da).
#'   \item \code{residueCount}: Number of amino acid residues in the structure.
#'   \item \code{densityMatthews}: Crystal density (Matthews coefficient).
#'   \item \code{phValue}: pH level of the crystallization solution.
#' }
#' Extra columns in the data frame will be ignored.
#'
#' @return A character vector containing the predicted class labels (e.g., "HYDROLASE").
#'
#' @import randomForest
#' @importFrom stats predict
#' @importFrom utils read.csv
#' @export
#'
#' @examples
#' # 1. Locate the example dataset included in the package
#' # (Note: 'BioPredProtein' must match your package name in DESCRIPTION)
#' example_path <- system.file("extdata", "test_data_sample.csv", package = "BioPredProtein")
#'
#' # 2. Check if file exists (to prevent errors during checks if data is missing)
#' if(example_path != "") {
#'   # 3. Load the test data
#'   test_data <- read.csv(example_path)
#'
#'   # 4. Perform prediction
#'   # The function automatically loads the internal model and returns labels
#'   predictions <- predict_protein_class(test_data)
#'
#'   # 5. Display results
#'   print(head(predictions))
#' } else {
#'   message("Example data not found. Please ensure the package is installed correctly.")
#' }
#'
#' # Example with manually created data
#' manual_data <- data.frame(
#'   structureMolecularWeight = c(35000, 45000),
#'   residueCount = c(320, 410),
#'   densityMatthews = c(2.4, 2.1),
#'   phValue = c(7.2, 6.0)
#' )
#' predict_protein_class(manual_data)

predict_protein_class <- function(new_data) {

  # 1. Locate Model File
  # ------------------------------------------------------------
  model_path <- system.file("extdata", "protein_rf_model.rds", package = "BioPredProtein")

  # 2. Ensure Model File Exists
  # ------------------------------------------------------------
  if (model_path == "") {
    stop("Error: Model file 'protein_rf_model.rds' not found in package 'inst/extdata'. Please reinstall the package.")
  }

  # 3. Load Pre-trained Random Forest Model
  # ------------------------------------------------------------
  rf_model <- readRDS(model_path)

  # 4. Input Data Validation
  # ------------------------------------------------------------
  required_cols <- c("structureMolecularWeight", "residueCount",
                     "densityMatthews", "phValue")

  # Check if input data contains all required columns
  # ------------------------------------------------------------
  missing_cols <- setdiff(required_cols, colnames(new_data))
  if(length(missing_cols) > 0) {
    stop(paste("Input data.frame is missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  # 5. Data Type Cleaning
  # ------------------------------------------------------------
  for(col in required_cols) {
    if(!is.numeric(new_data[[col]])) {
      new_data[[col]] <- as.numeric(new_data[[col]])
    }
  }

  # 6. Perform Prediction
  # ------------------------------------------------------------
  preds <- predict(rf_model, newdata = new_data, type = "response")

  # 7. Return
  # ------------------------------------------------------------
  return(as.character(preds))
}