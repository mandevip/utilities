# ==================================================
# Script: s-RO72.R
# Author: Peter B. Mandeville
# Modified: 2026-11-07
# Description: This interactive R utility estimates compound interest doubling
# times. It compares the standard Rule of 72 mental math shortcut against exact
# annual discrete compounding and continuous compounding limits, displaying 
# formatted comparative outputs and calculation variances.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Rule of 72 (RO72).
# ==================================================

# ---- Function to compute and format doubling estimates ----
calculate_doubling_time <- function(rate) {
  # 1. Rule of 72 Approximation
  rule_72_years <- 72 / rate

  # 2. Exact Annual Discrete Compounding: ln(2) / ln(1 + r)
  rate_decimal <- rate / 100
  exact_years <- log(2) / log(1 + rate_decimal)

  # 3. Continuous Compounding Limit: ln(2) * 100 / r
  continuous_years <- (log(2) * 100) / rate

  # Difference/Variance
  variance <- rule_72_years - exact_years

  cat(sprintf("\nAt a %.2f%% annual interest rate:\n", rate))
  cat(sprintf("  - Rule of 72 Estimate: ~%.2f years\n", rule_72_years))
  cat(sprintf("  - Exact (Annual):       %.2f years\n", exact_years))
  cat(sprintf("  - Estimation Variance:  %+.2f years\n", variance))
  cat(sprintf("  - Continuous Limit:     %.2f years\n", continuous_years))
  cat("----------------------------------------------\n\n")
}

# ---- Core Interactive Loop ----
run_ro72_calculator <- function() {
  cat("--- Rule of 72 Doubling Calculator ---\n")
  cat("Enter the annual interest rate (e.g., 8 for 8%).\n")
  cat("Type 'esc', 'q', 'quit', or 'exit' to end the session.\n")
  cat("----------------------------------------------\n\n")

  while (TRUE) {
    user_input <- trimws(readline(prompt = "Enter Interest Rate (%): "))

    # Check exit commands
    if (tolower(user_input) %in% c("esc", "q", "quit", "exit")) {
      cat("\nSession ended. Happy investing!\n")
      break
    }

    rate <- as.numeric(user_input)

    # Validation
    if (is.na(rate) || rate <= 0) {
      cat("Error: Please enter a valid positive number for the interest rate.\n")
      cat("----------------------------------------------\n\n")
      next
    }

    if (rate >= 100) {
      cat("Warning: Rates of 100% or above are unusual. Proceeding with calculation...\n")
    }

    calculate_doubling_time(rate)
  }
}

# ---- Entry Point Execution ----
if (interactive()) {
  run_ro72_calculator()
} else {
  # Command line execution support (e.g., Rscript s-RO72.R 8)
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 0 && !is.na(as.numeric(args[1]))) {
    calculate_doubling_time(as.numeric(args[1]))
  } else {
    cat("Non-interactive session detected. Pass a rate as a command line argument (e.g., Rscript s-RO72.R 7.5)\n")
  }
}

# ---- Final Message ----
cat("==== s-RO72.R Script Complete ====\n")
