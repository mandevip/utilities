# ==================================================
# Script: s-DCSVFC.R
# Author: Peter B. Mandeville
# Modified: 2026-11-07
# Description: This utility reads a CSV file, safely removes specified columns,
# and writes the resulting cleaned dataset to a target file. It preserves raw
# data types (preventing unwanted string/date auto-conversion), verifies column
# presence, logs dataset dimensions before and after processing, and warns the
# user if any targeted columns are missing.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Delete CSV File Columns (DCSVFC).
# ==================================================

# ---- Load Required Libraries ----
library(dplyr)
library(readr)
library(fs)

# ---- Configuration ----
input_file <- "titanic1.csv"
output_file <- "titanic2.csv"
fields_to_delete <- c("PassengerId", "Name")

# ---- Primary Execution Function ----
remove_csv_columns <- function(in_path, out_path, drop_cols) {
  # 1. Input Validation
  if (!file_exists(in_path)) {
    stop(sprintf("Aborted: Input file '%s' not found.", in_path))
  }

  # 2. Read Raw CSV (preserving raw character values without re-parsing)
  df_raw <- read_csv(in_path, col_types = cols(.default = "c"), show_col_types = FALSE)

  # 3. Verify Target Columns
  found_cols <- intersect(drop_cols, names(df_raw))
  missing_cols <- setdiff(drop_cols, names(df_raw))

  if (length(missing_cols) > 0) {
    warning(sprintf(
      "The following target columns were not found in '%s': %s",
      in_path, paste(missing_cols, collapse = ", ")
    ))
  }

  if (length(found_cols) == 0) {
    message("No specified target columns were present. Copying file as-is.")
    write_csv(df_raw, out_path)
    return(invisible(df_raw))
  }

  # 4. Remove Fields
  df_cleaned <- df_raw %>% select(-any_of(found_cols))

  # 5. Output Summary Metrics
  message(sprintf("Original dimensions: %d rows x %d columns", nrow(df_raw), ncol(df_raw)))
  message(sprintf("Cleaned dimensions:  %d rows x %d columns", nrow(df_cleaned), ncol(df_cleaned)))
  message(sprintf("Removed column(s):   %s", paste(found_cols, collapse = ", ")))

  # 6. Write Export File
  write_csv(df_cleaned, out_path, na = "")
  message(sprintf("Cleaned dataset successfully written to '%s'", out_path))
  message("---- s-DCSVFC script execution completed ----")

  return(invisible(df_cleaned))
}

# ---- Execute Call ----
remove_csv_columns(input_file, output_file, fields_to_delete)

# ---- Final Message ----
cat("==== s-DCSVFC.R Script Complete ====\n")
