# Clear the workspace
rm(list = ls())
library(rio)
library(moments)
library(dbhydroR)
library(dplyr)
library(corrplot)

file1 = import("L001_H2OT_Degrees Celsius.csv", colClasses = c("NULL", "character", "numeric"))
file2 = import("L001_AIRT_Degrees Celsius.csv", colClasses = c("NULL", "character", "numeric"))
print(file1)
print(file2)

colnames(file1)[1] <- "Date"
colnames(file2)[1] <- "Date"
merged_data <- merge(file1, file2, by = "Date", all = TRUE)
# Remove rows with 0 values in any column
merged_data <- merged_data %>%
  filter(across(everything(), ~. != 0))
# remove rows with missing values (NA) from the merged_data data frame,
merged_data <- merged_data[complete.cases(merged_data), ]
# Rename the columns
colnames(merged_data)[colnames(merged_data) == "L001_H2OT_Degrees Celsius"] <- "L001_H2OT_Degrees_Celsius"
colnames(merged_data)[colnames(merged_data) == "L001_AIRT_Degrees Celsius"] <- "L001_AIRT_Degrees_Celsius"
# Save merged_data as a CSV file
write.csv(merged_data, "merged_data_H20T_AIRT.csv", row.names = FALSE)
# Calculate the correlation matrix for the parameter columns
correlation_matrix <- cor(merged_data[, -1])

# Print the correlation matrix
print(correlation_matrix)
# Visualize the correlation matrix using corrplot
corrplot(correlation_matrix, method = "color", type = "lower", tl.col = "black",addCoef.col = "red")


# Fit the linear regression model
model <- lm(L001_H2OT_Degrees_Celsius ~ L001_AIRT_Degrees_Celsius, data = merged_data)

# Print the summary of the model
summary(model)

#Based on this output, the regression equation can be written as:
  
#L001_H2OT_Degrees_Celsius = 1.862667 + 0.936899 * L001_AIRT_Degrees_Celsius

#This equation can be used to predict the water surface temperature (L001_H2OT_Degrees_Celsius) based on the air temperature (L001_AIRT_Degrees_Celsius).
