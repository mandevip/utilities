# ==================================================
# Script: s-MPDFF.R
# Modified: 2026-11-07
# Author: Peter B. Mandeville
# Description: Merge PDF Files (MPDFF) merges two or more PDF files
#   into a single PDF file.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Merge PDF Files (MPDFF).
# ==================================================

# Load required package
if (!requireNamespace("qpdf", quietly = TRUE)) install.packages("qpdf")
library(qpdf)

# Define file paths
pdf_files <- c(
  "E:/Personal/Medical/Peter/2026-07-13 HL-Ultrasonido de cuello pg 1.pdf",
  "E:/Personal/Medical/Peter/2026-07-13 HL-Ultrasonido de cuello pg 2.pdf"
)
output_file <- "E:/Personal/Medical/Peter/2026-07-13 HL-Ultrasonido de cuello.pdf"

# Function to merge PDF files
merge_pdfs <- function(pdf_files, output_file) {
  # 1. Validate input: Ensure at least two files are provided
  if (length(pdf_files) < 2) {
    stop("Error: At least two PDF files are required for merging.")
  }

  # 2. Check if any files are missing
  missing_files <- pdf_files[!file.exists(pdf_files)]
  if (length(missing_files) > 0) {
    stop("Error: The following files are missing:\n", paste(missing_files, collapse = "\n"))
  }

  # 3. Create the output directory if it doesn't exist yet
  output_dir <- dirname(output_file)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  message("Merging ", length(pdf_files), " PDF files...")

  # 4. Execute the merge natively using qpdf wrapper
  status <- tryCatch(
    {
      qpdf::pdf_combine(input = pdf_files, output = output_file)
      TRUE
    },
    error = function(e) {
      message("Native qpdf failed: ", conditionMessage(e))
      FALSE
    }
  )

  # 5. Verify success
  if (status && file.exists(output_file)) {
    message("PDF files merged successfully into: ", output_file)
  } else {
    stop("Error: Output file was not created. Check your write permissions or if a file is open.")
  }
}

# Call the merge function
merge_pdfs(pdf_files, output_file)

# ---- Final Message ----
cat("==== s-MPDFF.R Script Complete ====\n")
