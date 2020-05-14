# Load packages
library(dplyr)
library(RcppArmadillo)

# Only sales prices > 0 for housing data

# Only take > 0; source: https://stackoverflow.com/questions/33535006/remove-rows-if-it-is-negative-number
df <- df_housing[df_housing$land_square_feet > 0, ]
df <- df[df$sale_price > 0, ]

# Get rid of NA values; source: https://stackoverflow.com/questions/48658832/how-to-remove-row-if-it-has-a-na-value-in-one-certain-column/48659101
df <- df[!is.na(df$sale_price), ]
df <- df[!is.na(df$land_square_feet), ]

X <- df %>% select("land_square_feet")
X <- as.numeric(X[[1]])
y <- df %>% select("sale_price")
y <- as.numeric(y[[1]])

# Trying it as a matrix, works better ...
X2 <- data.matrix(X)

# Examine datatype for each column
sapply(X, class)
sapply(y, class)


# Reorganizing crime data


## Want type of crime by year and zip code



# Join the crime information with the year the house data sold price





# Join census data as a control series



# Run some regressions and see what variables help the most (does crime help?)
# You may have to do this before running the regressions:
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

fit <- fastLm(X2, y)
summary(fit)

# Include in report table of findings for the different regressions and the p-values


# Use regression results to make score for each area / zip code over time
# (maybe based this score on the regression coefficients for the regions)



# Plot these on the Shiny map that the othter pair is working on

