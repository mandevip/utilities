# ==================================================
# Script: s-MCSVF.R
# Modified: 2026-11-07
# Author: Peter B. Mandeville
# Description: This R utility consolidates multiple CSV files with matching
# schemas into a single output file. Built on readr and dplyr, it validates
# file existence, handles mismatched schemas, filters out empty files, and
# prevents data type conflicts.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Merge CSV Files (MCSVF).
# ==================================================

library(dplyr)
library(readr) # Faster I/O and strict type specification

# --- Configuration ---
CONFIG <- list(
  input_files = c(
    "E:/Analysis/Utilities/MCSVF/PRTFL-2026-01-30-a.csv",
    "E:/Analysis/Utilities/MCSVF/PRTFL-2026-01-30-b.csv",
    "E:/Analysis/Utilities/MCSVF/PRTFL-2026-01-30-c.csv"
  ),
  output_file = "E:/Analysis/Utilities/MCSVF/PRTFL-2026-c.csv",
  # Set to TRUE to read all columns as character to avoid type conflicts before merging
  force_character_types = FALSE
)

# Function to read and validate a CSV file safely
read_csv_safe <- function(full_path, force_char = FALSE) {
  if (!file.exists(full_path)) {
    message("Warning: File not found - ", full_path)
    return(NULL)
  }

  col_types <- if (force_char) col_types <- readr::cols(.default = readr::col_character()) else NULL

  df <- tryCatch(
    readr::read_csv(full_path, col_types = col_types, show_col_types = FALSE),
    error = function(e) {
      message("Error reading ", full_path, ": ", e$message)
      return(NULL)
    }
  )

  if (!is.null(df) && nrow(df) == 0) {
    message("Note: File is empty and will be skipped - ", full_path)
    return(NULL)
  }

  return(df)
}

# Main processing engine
main <- function() {
  cat("Starting merge operation...\n")

  # Read files safely
  data_list <- lapply(
    CONFIG$input_files,
    read_csv_safe,
    force_char = CONFIG$force_character_types
  )

  # Remove NULL entries (failed reads or empty files)
  data_list <- Filter(Negate(is.null), data_list)

  if (length(data_list) == 0) {
    stop("Aborted: No valid, non-empty CSV files could be read.")
  }

  # Verify structural identity (column names)
  base_cols <- colnames(data_list[[1]])
  mismatched <- sapply(data_list, function(df) !identical(colnames(df), base_cols))

  if (any(mismatched)) {
    warning(
      sprintf(
        "Column mismatch detected in %d file(s). bind_rows() will match by column name.",
        sum(mismatched)
      )
    )
  }

  # Efficiently combine matching datasets
  combined_data <- tryCatch(
    bind_rows(data_list),
    error = function(e) {
      stop("Failed to bind rows due to data type conflicts. Set 'force_character_types = TRUE' in CONFIG. Details: ", e$message)
    }
  )

  if (nrow(combined_data) == 0) {
    stop("Aborted: Combined dataset contains zero records.")
  }

  # Write out final consolidated CSV
  readr::write_csv(combined_data, CONFIG$output_file)

  cat(sprintf(
    "Success! Merged %d file(s) into %d total rows.\nDestination: %s\n",
    length(data_list), nrow(combined_data), CONFIG$output_file
  ))
}

# Execute script
main()

# ---- Final Message ----
cat("==== s-MCSVF.R Script Complete ====\n")
