# These should be taken care of with the higher level Import_All.R:
# source("../Engm182_Project/Import_Scripts/Import_Crime_Data.R")
# head(df_crime)
library(tidyr)
library(dplyr)
#Dropping the rows whcih have blank in latitude or longitude column
df_crime2 <- drop_na(df_crime, Latitude, Longitude)

#Reverse geocoding to find the zip code for each Lonlat
library("ggmap")
dset_crime2 <- as.data.frame(df_crime2[,29:28]) 
loc <- dset_crime2
res <- lapply(seq(nrow(location)), function(i){ 
    revgeocode(location[i,], 
               output = c("all"), 
               messaging = FALSE, 
               sensor = FALSE, 
               override_limit = FALSE)
})
#Assigning weights to each crime
#Violations are the most minor of offenses. They have been assigned a weight of 1
#source: https://patrickparrottalaw.com/differences-between-a-violation-a-misdemeanor-and-a-felony/
df_crime2$weight <- 0
df_crime2$weight[which(df_crime2$LAW_CAT_CD=="VIOLATION")]=1

#Misdemeanours are more serious than violations but less severe than felonies, they can carry up to a year in jail and have score of 2
#source: https://patrickparrottalaw.com/differences-between-a-violation-a-misdemeanor-and-a-felony/
df_crime2$weight[which(df_crime2$LAW_CAT_CD=="MISDEMEANOR")]=2

#Felonies are the most serious of offenses and will be sub-classified
#Common law and statutes in most states divide felonies into first through fourth degree felonies, each carrying decreasing penalties
#First-degree felony: murder, rape, kidnapping, arson, fraud
#Second-degree felony: aggravated assault, felony assault, arson, manslaughter, possession of a controlled substance, child molestation
#Third-degree felony: assault and battery, elder abuse, transmission of pornography, driving under the influence, fraud, arson
#Fourth-degree felony: involuntary manslaughter, burglary, larceny, resisting arrest
#source: https://legaldictionary.net/felony/

df_crime2_felony <- subset(df_crime2, df_crime2$LAW_CAT_CD=="FELONY")
felonytypes <- unique(df_crime2_felony$OFNS_DESC)
felony_1stdegree <- c("RAPE", "THEFT-FRAUD", "ARSON", "KIDNAPPING & RELATED OFFENSES", "MURDER & NON-NEGL. MANSLAUGHTER", "KIDNAPPING", "KIDNAPPING AND RELATED OFFENSES", "NYS LAWS-UNCLASSIFIED FELONY" )
felony_2nddegree <- c("FELONY ASSAULT", "FORGERY", "SEX CRIMES", "DANGEROUS DRUGS", "DANGEROUS WEAPONS")
felony_3rddegree <- c("INTOXICATED/IMPAIRED DRIVING","ROBBERY", "CRIMINAL MISCHIEF & RELATED OF", "PROSTITUTION & RELATED OFFENSES")
felony_4thdegree <- c("GAMBLING","", "BURGLARY","GRAND LARCENY", "GRAND LARCENY OF MOTOR VEHICLE", "MISCELLANEOUS PENAL LAW", "POSSESSION OF STOLEN PROPERTY", "CHILD ABANDONMENT/NON SUPPORT", "HOMICIDE-NEGLIGENT-VEHICLE", "HOMICIDE-NEGLIGENT,UNCLASSIFIE", "ENDAN WELFARE INCOMP")

df_crime2$weight[which(df_crime2$OFNS_DESC %in% felony_1stdegree == TRUE)]=6
df_crime2$weight[which(df_crime2$OFNS_DESC %in% felony_2nddegree == TRUE)]=5
df_crime2$weight[which(df_crime2$OFNS_DESC %in% felony_3rddegree == TRUE)]=4
df_crime2$weight[which(df_crime2$OFNS_DESC %in% felony_4thdegree == TRUE)]=3

df_crime <- df_crime2
# save(df_crime, file='Data_Crime.rda')

#Extract month and year for each crime
df_crime3 <- subset(df_crime2, select = c(CMPLNT_FR_DT, OFNS_DESC, LAW_CAT_CD, Longitude, Latitude, weight))
head(df_crime3)


