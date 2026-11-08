# ==================================================
# Script: s-DS.R
# Modified: 2026-11-07
# Author: Peter B. Mandeville (Refactored)
# Description: This lightweight R utility recursively maps the directory
# hierarchy of a source drive or folder and saves the output to a formatted,
# dated text file. It allows toggling between a directory-only view and a full
# file-and-folder view, while automatically excluding system-level folders like
# $RECYCLE.BIN to maximize execution speed and output readability.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Directory Structure (DS).
# ==================================================

# --- Load Reguired Libraries ---
library(fs)

# --- Configuration ---
source_dir <- "E:/"
output_dir <- "E:/BackupReports"
include_files <- FALSE # TRUE = dirs + files; FALSE = dirs only

# --- Exclusions ---
# Regex pattern to ignore common system folders and recycle bin
exclude_regex <- "\\$RECYCLE\\.BIN|System Volume Information"

# Ensure output directory exists
if (!dir_exists(output_dir)) {
  dir_create(output_dir)
}

# Generate output file path
file_suffix <- if (include_files) "with_files" else "directories_only"
output_file <- file.path(output_dir, sprintf("directory_structure_%s_%s.txt", file_suffix, Sys.Date()))

tree_type <- if (include_files) "any" else "directory"

cat("Scanning drive structure...\n")

# --- Execution with Safe Output Redirection ---
generate_structure <- function() {
  # Safely handle sink closure regardless of script termination
  on.exit(
    {
      if (sink.number() > 0) sink()
    },
    add = TRUE
  )

  # Connect output stream directly to file
  con <- file(output_file, open = "wt")
  on.exit(close(con), add = TRUE)

  sink(con)

  # Print header
  cat(sprintf("Directory Structure Report - %s\n", Sys.time()))
  cat(sprintf("Source: %s\n", source_dir))
  cat(rep("-", 50), "\n\n")

  # Render drive tree (suppressing EPERM warnings on protected system directories)
  suppressWarnings(
    dir_tree(
      path = source_dir,
      recurse = TRUE,
      fail = FALSE,
      type = tree_type,
      regexp = exclude_regex,
      invert = TRUE
    )
  )
}

tryCatch(
  {
    generate_structure()
    cat(sprintf("Directory structure successfully written to:\n%s\n", output_file))
  },
  error = function(e) {
    cat("An error occurred during execution:\n", conditionMessage(e), "\n")
  }
)

# ---- Final Message ----
cat("==== s-DS.R Script Complete ====\n")
