# utilities
This repository houses a collection of professional, production-grade R utility scripts developed for financial analysis, system maintenance, and data management. Each utility prioritizes defensive programming, robust error handling, clear console feedback, and comprehensive operational documentation. 

# Included Utilities:

Convert PDF Pages to PNG (CPDF2PNG.R): Extracts specified pages from a PDF document and renders them as high-resolution PNG image files. Utilizing `pdftools` with vectorized page extraction, it provides custom DPI resolution controls, defensive page-range validation, and automatic output directory creation.

Delete CSV File Columns (DCSVFC.R): Reads a CSV file, safely removes specified columns, and writes the resulting cleaned dataset to a target file. It preserves raw data types (preventing unwanted string/date auto-conversion), verifies column presence, logs dataset dimensions before and after processing, and warns the user if any targeted columns are missing.

Directory Structure (DS.R): Recursively maps the directory hierarchy of a source drive or folder and saves the output to a formatted, dated text file. It allows toggling between a directory-only view and a full file-and-folder view, while automatically excluding system-level folders like `RECYCLE.BIN` to maximize execution speed and output readability.

Directory Backup (DB.R): Automates full directory backups from a source drive to an external disk. It includes built-in safety features such as dry-run simulation, automated pre-filter exclusions, native available disk space validation, long-path detection (`>260` characters), and post-backup logging.

Merge CSV Files (MCSVF.R): Consolidates multiple CSV files with matching schemas into a single output file. Built on `readr` and `dplyr`, it validates file existence, handles mismatched schemas, filters out empty files, and prevents data type conflicts.

Merge PDF Files (MPDFF.R): Combines two or more PDF documents into a single consolidated PDF file. Powered by `qpdf`'s native C++ bindings, it delivers high-performance merging while validating file availability, protecting against accidental file overwrites, and ensuring destination path creation.

Rule of 72 (RO72.R): An interactive calculator that estimates compound interest doubling times. It compares the standard Rule of 72 mental math shortcut against exact annual discrete compounding and continuous compounding limits, displaying formatted comparative outputs and calculation variances.

Value Added Between 2 Dates (VAB2D.R): Evaluates investment performance across monthly snapshot intervals using the Modified Dietz method and Time-Weighted Return (TWR) compounding. It computes period-by-period net gains, Rate of Return (RoR), and Compound Annual Growth Rate (CAGR), appending an overall summary row for the full date range.

# Repository Structure

Each utility script and its corresponding technical manual (`m-*.odt` and `m-pdf`) are self-contained within their own dedicated subdirectory:

|-- Convert PDF Pages to PNG (CPDF2PNG.R)
|   |-- s-CPDF2PNG.R
|   |-- m-CPDF2PNG.odt
|   |-- m-CPDF2PNG.pdf
|-- Delete CSV File Columns (DCSVFC.R)
|   |-- s-DCSVFC.R
|   |-- m-DCSVFC.odt
|   |-- m-DCSVFC.pdf
|-- Directory Backup (DB.R)
|   |-- s-DB.R
|   |-- m-DB.odt
|   |-- m-DB.pdf
|-- Directory Structure (DS.R)
|   |-- s-DS.R
|   |-- m-DS.odt
|   |-- m-DS.pdf
|-- Merge CSV Files (MCSVF.R)                                          
|   |-- s-MCSVF.R
|   |-- m-MCSVF.odt
|   |-- m-MCSVF.pdf
|-- Merge PDF Files (MPDFF.R)                                          
|   |-- s-MPDFF.R
|   |-- m-MPDFF.odt
|   |-- m-MPDFF.pdf
|-- Rule of 72 (RO72.R)
|   |-- s-RO72.R
|   |-- m-RO72.odt
|   |-- m-RO72.pdf
|-- Value Added Between 2 Dates (VAB2D.R)
|   |-- s-VAB2D.R
|   |-- m-VAB2D.odt
|   |-- m-VAB2D.pdf
|   |-- HFP-Results-c
|   |-- HFP-Results-o
|-- README.md
|-- LICENSE-CODE            
|-- MIT License

System Requirements & Dependencies:

To execute the scripts and reference the documentation.

    • Environment: R (v4.0+) and RStudio
      
    • Core R Packages: tidyverse, dplyr, readr, lubridate, fs, qpdf, pdftools, stringr, purrr
      
Citation:

If you use this codebase in your academic, professional, or open-source research, please cite:

@manual{utilities,
  author       = {Mandeville, Peter B.},
  title        = {Utilities},
  year         = {2026},
  publisher    = {GitHub},
  url          = {[https://github.com/YOUR_USERNAME/YOUR_REPOSITORY](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY)}
}

License
This repository uses dual licensing:

    • Codebase & R Scripts: Distributed under the MIT License (see LICENSE-CODE).
      
    • Manuals & Documentation: Distributed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).
