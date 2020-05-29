library(ggplot2)
library(dplyr)

filtered_merged  = merged_housing_crime %>%
        filter(zip_code == 11367)


ggplot(filtered_merged, aes(x = month_char, y = avg_price_per_sqft,  group = 1))+geom_line()

ggplot(filtered_merged, aes(x = month_char, y = weight_normalized, group = 1))+geom_line()

ggplot(filtered_merged, aes(x = month_char, y = total_proceeds, group = 1))+ geom_line()+scale_x_continuous()

?addPopupGraphs