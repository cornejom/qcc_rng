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

# 5. Extract distinct stages and target chart type
stages <- unique(df$stage)
chart_type <- config$qcc_params$chart_type

# 6. Group by "stage" and call the qcc function for each distinct stage
qcc_list <- lapply(stages, function(s) {
  # Subset data for the current stage
  stage_data <- df[df$stage == s, ]
  
  # Identify columns named xi where i is an integer (e.g., x1, x2, x3)
  xi_cols <- grep("^x\\d+$", names(stage_data), value = TRUE)
  
  # Extract only those columns for the qcc data argument
  qcc_data <- stage_data[, xi_cols, drop = FALSE]
  
  # Execute qcc (do not override the plot argument)
  qcc(data = qcc_data, type = chart_type)
})

# 7. Change the names of the elements in the list to format "stage_i"
names(qcc_list) <- paste0("stage_", seq_along(qcc_list))

# 8. Consolidate the desired vectors from the qcc objects into one tidy data frame
tidy_list <- lapply(seq_along(qcc_list), function(i) {
  q_obj <- qcc_list[[i]]
  
  # Extract limits specifically from limits[1,1] and limits[1,2]
  lim_1 <- q_obj$limits[1, 1]
  lim_2 <- q_obj$limits[1, 2]
  
  # Create a data frame for the current stage and rename limits to LCL and UCL
  data.frame(
    stage = i,
    group = seq_len(length(q_obj$statistics)),
    xbar = as.numeric(q_obj$statistics),
    center = as.numeric(q_obj$center),
    LCL = as.numeric(lim_1),
    UCL = as.numeric(lim_2),
    stringsAsFactors = FALSE
  )
})

# Stack all individual data frames into a single consolidated data frame
final_df <- do.call(rbind, tidy_list)

# Logical indicators of non-integer numeric columns
roundables <- sapply(final_df, function(x) is.numeric(x) & !(is.integer(x)))
final_df[,roundables] <- lapply(final_df[roundables], round, digits=2)

# 9. Save the final data frame to file "control_chart_stats.csv" in the same directory
write.csv(final_df, output_file, row.names = FALSE)
