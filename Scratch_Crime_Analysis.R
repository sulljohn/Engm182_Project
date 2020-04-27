# Barplot of crimes by frequency
# Source: http://www.r-tutor.com/elementary-statistics/qualitative-data/bar-graph
crimetype = df_crime$OFNS_DESC
crimetype.freq = table(crimetype)
barplot(crimetype.freq)

# Histogram of dates
# Source: https://stat.ethz.ch/R-manual/R-devel/library/graphics/html/hist.POSIXt.html
df$Date <- as.Date(df_crime$CMPLNT_FR_DT, "%m/%d/%Y")
hist(df_crime$Date, "years", freq = TRUE)