# ==================================================
# Script: s-DB.R
# Modified: 2026-11-07
# Author: Peter B. Mandeville
# Description: This R script automates full directory backups from a source drive
# to an external disk. It includes built-in safety features such as dry-run
# simulation, automated pre-filter exclusions, native available disk space
# validation, long-path detection (>260 characters), and post-backup logging.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Directory Backup (DB).
# ==================================================

# --- Load Required Libraries ---
library(fs)

# ---- Configuration ----
dry_run <- FALSE

source_dir <- "E:/"
report_dir <- "E:/BackupReports"
backup_date <- format(Sys.Date(), "%Y-%m-%d")
backup_base <- "D:/STORAGE (E)"
backup_dir <- sprintf("%s %s", backup_base, backup_date)

if (!grepl("/$", source_dir)) source_dir <- paste0(source_dir, "/")

# ---- Directory Validation ----
if (!dir_exists(source_dir)) stop(sprintf("Source directory missing: %s", source_dir))
if (dir_exists(backup_dir)) stop(sprintf("Backup destination already exists: %s", backup_dir))

if (!dry_run) {
  dir_create(report_dir)
  dir_create(backup_dir)
}

# ---- Pre-filter Directory Scanning ----
cat("Scanning source directory...\n")
exclude_regex <- "\\$RECYCLE\\.BIN|System Volume Information|^E:/Movies|^E:/Music"

# Use fs::dir_ls to skip scanning excluded top-level paths directly
suppressWarnings(
  all_items <- dir_ls(
    source_dir,
    recurse = TRUE,
    type = "file",
    fail = FALSE,
    regexp = exclude_regex,
    invert = TRUE
  )
)

if (length(all_items) == 0) {
  stop("No files found in source directory. Exiting.")
}

cat(sprintf("Found %d valid files to backup.\n", length(all_items)))

# ---- Disk Space Validation ----
source_size_bytes <- sum(file_size(all_items), na.rm = TRUE)
source_size_gb <- source_size_bytes / 1e9

# Helper to get free disk space in bytes on Windows via PowerShell
get_free_space <- function(path) {
  drive <- substr(normalizePath(path, mustWork = FALSE), 1, 2)
  ps_cmd <- sprintf("(Get-PSDrive %s).Free", substr(drive, 1, 1))
  res <- suppressWarnings(system2("powershell", args = c("-Command", ps_cmd), stdout = TRUE, stderr = TRUE))
  free_bytes <- as.numeric(trimws(res[grep("^[0-9]+$", res)]))

  if (length(free_bytes) == 0 || is.na(free_bytes)) {
    warning("Could not query disk space via PowerShell. Skipping check.")
    return(Inf)
  }
  return(free_bytes)
}

free_space_bytes <- get_free_space(backup_base)
free_space_gb <- free_space_bytes / 1e9

cat(sprintf("Source total size: %.2f GB\n", source_size_gb))
cat(sprintf("Backup drive free space: %.2f GB\n", free_space_gb))

if (is.na(free_space_gb) || source_size_bytes > free_space_bytes) {
  stop(sprintf("Insufficient disk space. Needed: %.2f GB | Available: %.2f GB", source_size_gb, free_space_gb))
}

# ---- Log File List ----
if (!dry_run) {
  output_file <- file.path(report_dir, sprintf("file_paths_%s.txt", Sys.Date()))
  writeLines(sprintf("%d. %s", seq_along(all_items), all_items), output_file)
}

# ---- Backup Process ----
start_time <- Sys.time()
total_files <- length(all_items)
long_paths <- character(0) # Preallocate character vector

cat("Starting backup process...\n")

for (i in seq_along(all_items)) {
  item <- all_items[i]

  # Bypass path_rel if the source path itself exceeds the 260-char limit
  if (nchar(item) >= 260) {
    long_paths <- c(long_paths, item)
    next
  }

  # Construct relative target path safely with suppression
  rel_path <- suppressWarnings(tryCatch(path_rel(item, start = source_dir), error = function(e) ""))

  if (length(rel_path) == 0 || rel_path == "" || is.na(rel_path)) {
    long_paths <- c(long_paths, item)
    next
  }

  dest_path <- file.path(backup_dir, rel_path)

  # Check destination path MAX_PATH limit
  if (nchar(dest_path) >= 260) {
    long_paths <- c(long_paths, item)
    next
  }

  # Apply Windows extended-length prefix (\\?\) using BACKSLASHES (required for \\?\ API)
  item_win <- normalizePath(item, winslash = "\\", mustWork = FALSE)
  dest_win <- normalizePath(dest_path, winslash = "\\", mustWork = FALSE)

  if (.Platform$OS.type == "windows") {
    if (!grepl("^\\\\\\\\\\?\\\\", item_win)) item_win <- paste0("\\\\?\\", item_win)
    if (!grepl("^\\\\\\\\\\?\\\\", dest_win)) dest_win <- paste0("\\\\?\\", dest_win)
  }

  if (!dry_run) {
    tryCatch(
      {
        dir_create(path_dir(dest_path))
        file.copy(item_win, dest_win, overwrite = TRUE)
      },
      error = function(e) {
        long_paths <<- c(long_paths, item)
      }
    )
  }

  if (i %% 100 == 0 || i == total_files) {
    cat(sprintf("[%d/%d] Processed: %s\n", i, total_files, rel_path))
  }
}

# ---- Generate Backup Report ----
elapsed_secs <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
hours <- as.integer(elapsed_secs %/% 3600)
minutes <- as.integer((elapsed_secs %% 3600) %/% 60)
seconds <- as.integer(elapsed_secs %% 60)

files_written <- if (!dry_run) length(dir_ls(backup_dir, recurse = TRUE, type = "file")) else 0

report <- sprintf(
  "Backup Report\n----------------\nSource Directory: %s\nBackup Directory: %s\nTotal Files Scanned: %d\nFiles Written: %d\nLong Paths Excluded (>260 chars): %d\nElapsed Time: %02d:%02d:%02d\nFinished: %s\n",
  source_dir, backup_dir, total_files, files_written, length(long_paths),
  hours, minutes, seconds, Sys.time()
)

cat(report)

# Write reports to file
if (!dry_run) {
  writeLines(report, file.path(report_dir, sprintf("backup_report_%s.txt", backup_date)))

  if (length(long_paths) > 0) {
    long_paths_file <- file.path(report_dir, sprintf("long_paths_%s.txt", backup_date))
    writeLines(long_paths, long_paths_file)
    cat(sprintf("Skipped paths log written to: %s\n", long_paths_file))
  }
}

# ---- Final Message ----
cat("==== s-DB.R Script Complete ====\n")
