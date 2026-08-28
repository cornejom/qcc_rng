# Load necessary libraries
library(yaml)
library(qcc)
library(here) # Used to robustly locate the project root directory

# 1. Locate and read the YAML configuration file from the project's root directory
config_path <- here::here("config.yaml")
config <- yaml::read_yaml(config_path)

# 2. Construct directory and file paths based on the config file
data_dir <- here::here(config$directories$data)
input_dir <- file.path(data_dir, "output")
input_file <- file.path(input_dir, "RNG_for_qcc.csv")
output_file <- file.path(input_dir, "control_chart_stats.csv")

# 3. Read the CSV file into a data frame
df <- read.csv(input_file, stringsAsFactors = FALSE)

# 4. Sort the data frame by stage and batch
df <- df[order(df$stage, df$batch), ]

# 5. Extract distinct stages and parameters from the configuration
stages <- unique(df$stage)
chart_type <- config$qcc_params$chart_type

# Extract rounding digits from YAML (checking within qcc_params or root level)
round_digits <- if (!is.null(config$qcc_params$round_digits)) {
  config$qcc_params$round_digits
} else {
  config$round_digits 
}

# 6. Group by "stage" and call the qcc function for each distinct stage
qcc_list <- list()
max_stage_val <- max(stages)

for (i in seq_along(stages)) {
  s <- stages[i]
  
  # Subset data for the current stage
  stage_data <- df[df$stage == s, ]
  
  # Identify columns named xi where i is an integer (e.g., x1, x2, x3)
  xi_cols <- grep("^x\\d+$", names(stage_data), value = TRUE)
  
  # Extract only those columns for the qcc data argument
  qcc_data <- stage_data[, xi_cols, drop = FALSE]
  
  # For the highest value of "stage", use center and limits from the previous stage
  if (s == max_stage_val && i > 1) {
    prev_qcc <- qcc_list[[i - 1]]
    qcc_list[[i]] <- qcc(
      data = qcc_data, 
      type = chart_type, 
      center = prev_qcc$center, 
      limits = prev_qcc$limits
    )
  } else {
    # Execute qcc standardly (do not override the plot argument)
    qcc_list[[i]] <- qcc(data = qcc_data, type = chart_type)
  }
}

# 7. Change the names of the elements in the list to format "stage_i"
names(qcc_list) <- paste0("stage_", seq_along(qcc_list))

# 8. Consolidate the desired vectors from the qcc objects into one tidy data frame
tidy_list <- lapply(seq_along(qcc_list), function(i) {
  q_obj <- qcc_list[[i]]
  
  # Create a data frame for the current stage
  stage_df <- data.frame(
    stage = as.integer(i),
    group = as.integer(seq_len(length(q_obj$statistics))),
    statistics = as.numeric(q_obj$statistics),
    center = as.numeric(q_obj$center),
    LCL = as.numeric(q_obj$limits[1, 1]),
    UCL = as.numeric(q_obj$limits[1, 2]),
    stringsAsFactors = FALSE
  )
  
  # Rename the "statistics" column to match the chart_type parameter
  names(stage_df)[names(stage_df) == "statistics"] <- chart_type
  
  return(stage_df)
})

# Stack all individual data frames into a single consolidated data frame
final_df <- do.call(rbind, tidy_list)

# 9. Override values of center, LCL, and UCL for the last stage
max_stage <- max(final_df$stage)

if (max_stage > 1) {
  # Identify the last row of the previous stage
  prev_stage_rows <- which(final_df$stage == (max_stage - 1))
  last_row_idx <- tail(prev_stage_rows, 1)
  
  # Extract the values to carry forward
  carry_center <- final_df$center[last_row_idx]
  carry_LCL <- final_df$LCL[last_row_idx]
  carry_UCL <- final_df$UCL[last_row_idx]
  
  # Apply these values to all rows in the maximum stage
  curr_stage_rows <- which(final_df$stage == max_stage)
  final_df$center[curr_stage_rows] <- carry_center
  final_df$LCL[curr_stage_rows] <- carry_LCL
  final_df$UCL[curr_stage_rows] <- carry_UCL
}

# 10. Round all non-integer numeric columns to the specified decimal digits
for (col in names(final_df)) {
  # Check if column is numeric but NOT strictly an integer class
  if (is.numeric(final_df[[col]]) && !is.integer(final_df[[col]])) {
    final_df[[col]] <- round(final_df[[col]], round_digits)
  }
}

# 11. Save the final data frame to file "control_chart_stats.csv" in the same directory
write.csv(final_df, output_file, row.names = FALSE)