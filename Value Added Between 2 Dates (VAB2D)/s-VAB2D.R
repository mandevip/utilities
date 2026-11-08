# ==================================================
# Script: s-VAB2D.R
# Author: Peter B. Mandeville
# Modified: 2026-11-07
# Description: This financial utility evaluates investment performance across
# monthly snapshot intervals using the Modified Dietz method and Time-Weighted
# Return (TWR) compounding. It computes period-by-period net gains, Rate of
# Return (ROR), and Compound Annual Growth Rate (CAGR),appending an overall 
# summary row for the full date range.
#
# Copyright (c) 2026 Peter B. Mandeville
# Licensed under the MIT License.
# See MIT LICENSE file in the project root for full license information.
#
# Preferred Citation:
#   Mandeville, P. B. (2026). Utilities: Value Added Between 2 Dates (VAB2D).
# ==================================================

# ---- Load Required Libraries ----
library(dplyr)
library(readr)
library(lubridate)
library(fs)

# ---- Configuration ----
options(scipen = 999999) # Prevent scientific notation
input_file <- "HFP-History.csv"
output_file <- "HFP-Results-c.csv"
start_date <- as.Date("2026-01-01")
end_date <- as.Date("2026-11-01")

# ---- Validation Gate ----
if (!file_exists(input_file)) {
  stop(sprintf("Aborted: Input file '%s' not found.", input_file))
}

# ---- Load, Clean, and Sort Full Data ----
raw_data <- read_csv(input_file, show_col_types = FALSE) %>%
  mutate(
    Date     = as.Date(Date),
    CashFlow = ifelse(is.na(CashFlow), 0, parse_number(as.character(CashFlow))),
    Value    = ifelse(is.na(Value), 0, parse_number(as.character(Value)))
  ) %>%
  arrange(Date)

# ---- Process Intervals and Map Timeline Sequentially ----
processed_data <- raw_data %>%
  mutate(
    # Compute true period month string by subtracting 1 month from snapshot date
    PeriodDate = Date %m-% months(1),
    Month      = format(PeriodDate, "%Y-%m"),
    Start_Val  = lag(Value),
    End_Val    = Value,
    Net_Flow   = CashFlow,

    # Gain calculation
    Gain       = End_Val - Start_Val - Net_Flow,

    # Mid-month assumption for cash flows (Modified Dietz equal weight)
    Avg_Cap    = Start_Val + (0.5 * Net_Flow)
  ) %>%
  filter(Date > start_date & Date <= end_date)

# ---- Format Monthly Performance Table ----
results <- processed_data %>%
  filter(!is.na(Start_Val)) %>%
  mutate(
    RoR_num  = round(if_else(Avg_Cap != 0, Gain / Avg_Cap, 0), 4),
    CAGR_num = round(((1 + RoR_num)^12) - 1, 4),
    Gain     = round(Gain, 2),
    RoR      = formatC(RoR_num, format = "f", digits = 4),
    CAGR     = formatC(CAGR_num, format = "f", digits = 4)
  ) %>%
  select(Month, Start_Val, End_Val, Net_Flow, Gain, RoR, CAGR)

if (nrow(results) == 0) {
  stop("No valid performance records found for the specified date range.")
}

# ---- Compute Overall Summary Metrics ----
overall_start_value <- results$Start_Val[1]
overall_end_value <- results$End_Val[nrow(results)]
overall_net_flows <- sum(results$Net_Flow)
overall_gain <- overall_end_value - overall_start_value - overall_net_flows

# ---- Overall RoR via Time-Weighted Return (TWR) ----
overall_RoR_raw <- prod(1 + as.numeric(results$RoR)) - 1

# ---- Calculate Exact Time Delta for Annualized Return (CAGR) ----
first_perf_date <- as.Date(paste0(results$Month[1], "-01"))
last_perf_date <- as.Date(paste0(results$Month[nrow(results)], "-01")) %m+% months(1)
total_days <- as.numeric(difftime(last_perf_date, first_perf_date, units = "days"))
overall_CAGR_raw <- if_else(total_days > 0, (1 + overall_RoR_raw)^(365.25 / total_days) - 1, 0)

# ---- Create Summary Row ----
overall_results <- tibble(
  Month     = "Overall",
  Start_Val = overall_start_value,
  End_Val   = overall_end_value,
  Net_Flow  = overall_net_flows,
  Gain      = round(overall_gain, 2),
  RoR       = formatC(round(overall_RoR_raw, 4), format = "f", digits = 4),
  CAGR      = formatC(round(overall_CAGR_raw, 4), format = "f", digits = 4)
)

# ---- Combine and Export ----
final_results <- bind_rows(results, overall_results)
write_csv(final_results, output_file, na = "")

# ---- Terminal Confirmation ----
cat("\n--- Analysis Complete ---\n")
cat(sprintf("Input File:   %s\n", input_file))
cat(sprintf("Output File:  %s\n", output_file))
cat(sprintf("Overall RoR:  %.2f%%\n", overall_RoR_raw * 100))
cat(sprintf("Overall CAGR: %.2f%%\n", overall_CAGR_raw * 100))

# ---- Final Message ----
cat("==== s-VAB2D.R Script Complete ====\n")
