library(dbhydroR)
library(data.table)

station_ids <- c("NCENTER", "NES135", "NES191", "OISLAND", "PALMOUT", 
                 "PALMOUT1", "PALMOUT2", "PALMOUT3", "PELBAY3", "POLESOUT", 
                 "POLESOUT1", "POLESOUT2", "POLESOUT3", "RITTAE2", 
                 "TIN13700", "TIN16100")
date_min <- "1950-01-01"
date_max <- format(Sys.Date(), "%Y-%m-%d")
test_names <- c("DEPTH, TOTAL",
                "CHLORIDE",
                "CHLOROPHYLL-C",
                "VOLATILE SUSPENDED SOLIDS",
                "NITRATE-N",
                "PH, FIELD",
                "DISSOLVED OXYGEN",
                "SP CONDUCTIVITY, FIELD",
                "Temperature",
                "AMMONIA-N",
                "TOTAL SUSPENDED SOLIDS",
                "NITRATE+NITRITE-N",
                "TURBIDITY",
                "COLOR",
                "PHOSPHATE, TOTAL AS P",
                "PHOSPHATE, DISSOLVED AS P",
                "PHOSPHATE, ORTHO AS P",
                "KJELDAHL NITROGEN, TOTAL",
                "KJELDAHL NITROGEN, DIS",
                "NITRITE-N",
                "HARDNESS AS CACO3",
                "CALCIUM",
                "MAGNESIUM","SODIUM",
                "POTASSIUM",
                "ALKALINITY, TOT, CACO3",
                "CAROTENOIDS",
                "PHEOPHYTIN",
                "CHLOROPHYLL-A",
                "CHLOROPHYLL-B",
                "CHLOROPHYLL-A, CORRECTED",
                "CHLOROPHYLL-B (LC)",
                "PHEOPHYTIN-A(LC)",
                "CHLOROPHYLL-A(LC)",
                "TOTAL NITROGEN",
                "NITROGEN, TOTAL DISSOLVED")


for (station_id in station_ids) {
  water_quality_data <- get_wq(station_id = station_id,
                               date_min = date_min,
                               date_max = date_max,
                               test_name = test_names)
  
  # Create a new data frame to store the desired format
  new_data <- data.frame(
    date = character(),
    station = character(),
    test_name = character(),
    unit = character(),
    value = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Loop through the columns of the original data and reshape it to the desired format
  for (col in sort(colnames(water_quality_data)[-1])) {
    parameter <- col
    data <- na.omit(data.frame(date = water_quality_data$date, value = water_quality_data[[col]], stringsAsFactors = FALSE))
    data$parameter <- parameter
    # Extract station, test name, and unit from the parameter column
    data$station_id <- gsub("^(.*?)_.*", "\\1", parameter)
    data$test_name <- gsub(".*_(.*?)_.*", "\\1", parameter)
    data$unit <- gsub(".*_(.*?)$", "\\1", parameter)
    # Reorder the columns in the data frame
    data <- data[, c("date", "station_id", "test_name", "unit", "value")]
    new_data <- rbind(new_data, data)
  }
  
  
  # Convert the date column to proper date format
  new_data$date <- as.Date(new_data$date, format = "%m/%d/%Y")
  
  # Sort the data by date and then by parameter
  new_data <- new_data[order(new_data$date, new_data$test_name), ]
  
  # Convert the date column back to the desired format
  new_data$date <- format(new_data$date, "%m/%d/%Y")
  
  # Sort the data by parameter in alphabetical order
  new_data <- new_data[order(new_data$test_name), ]
  
  # Write the data to a CSV file
  file_name <- paste0("dbhydro_waterquality_", station_id, ".csv")
  write.csv(new_data, file = file_name, row.names = FALSE)
}
#combining all the different station_id files

combined_data <- data.table()

for (station_id in station_ids) {
  file_name <- paste0("dbhydro_waterquality_", station_id, ".csv")
  
  if (file.exists(file_name)) {
    data <- fread(file_name)
    data$station_id <- station_id
    
    combined_data <- rbindlist(list(combined_data, data), fill = TRUE)
  }
}

# Write the combined data to a CSV file
write.csv(combined_data, file = "AAc.csv", row.names = FALSE)
