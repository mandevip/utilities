# ==================================================
# Script: s-CPDF2PNG.R
# Author: Peter B. Mandeville
# Modified: 2026-11-07
# Description: This R utility extracts specified pages from a PDF document and
# renders them as high-resolution PNG image files. Utilizing pdftools with
# vectorized page extraction, it provides custom DPI resolution controls,
# defensive page-range validation, and output directory auto-creation.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Convert PDF pages to PNG (CPDF2PNG).
# ==================================================

# ---- Load Required Libraries ----
suppressPackageStartupMessages({
  library(pdftools)
  library(fs)
})

# ---- Configuration ----
pdf_file <- "EDA3-HD9-cad 2026-07-27_12-32-49.pdf"
pages <- c(1, 2)
out_file_base <- "EDA3-HD9-cad"
out_dir <- "include" # Relative path preferred for portability
dpi <- 300

# ---- Core Function ----
extract_plot_pages <- function(pdf_file, pages, out_file_base, out_dir, dpi = 300) {
  # Defensive check: Input file existence
  if (!file_exists(pdf_file)) {
    stop("Error: The input PDF file does not exist at: ", pdf_file)
  }

  # Check PDF page count bounds
  info <- pdf_info(pdf_file)
  total_pages <- info$pages
  invalid_pages <- pages[pages < 1 | pages > total_pages]

  if (length(invalid_pages) > 0) {
    stop(sprintf(
      "Error: Requested page(s) %s out of range. Document has %d pages.",
      paste(invalid_pages, collapse = ", "), total_pages
    ))
  }

  # Ensure output directory exists
  if (!dir_exists(out_dir)) {
    dir_create(out_dir)
  }

  # Pre-generate vector of output filenames
  out_pngs <- file.path(out_dir, sprintf("%s_page_%d.png", out_file_base, pages))

  # Vectorized batch conversion via pdftools
  tryCatch(
    {
      pdftools::pdf_convert(
        pdf       = pdf_file,
        format    = "png",
        pages     = pages,
        filenames = out_pngs,
        dpi       = dpi,
        verbose   = FALSE
      )

      for (png_path in out_pngs) {
        cat(sprintf("Saved PNG: %s\n", png_path))
      }
    },
    error = function(e) {
      stop("Failed during PDF conversion: ", conditionMessage(e))
    }
  )
}

# ---- Execution ----
extract_plot_pages(
  pdf_file      = pdf_file,
  pages         = pages,
  out_file_base = out_file_base,
  out_dir       = out_dir,
  dpi           = dpi
)

# ---- Final Message ----
cat("==== s-CPDF2PNG.R Script Complete ====\n")
