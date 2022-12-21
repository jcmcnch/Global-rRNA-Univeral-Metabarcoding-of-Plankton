## 2022-12-17: G1 - confirm DNA ID provided by Carlson lab matches the DNA ID found in final
## ASV table outputs from JM.
## G2 - match CTD metadata for each sample based on DNA ID.
## ******* All raw CTD and bottle data for I08S were downloaded from
## https://cchdo.ucsd.edu/cruise/33RR20070204 *******
## ******* All raw CTD and bottle data for I09N were downloaded from 
## https://cchdo.ucsd.edu/cruise/33RR20070322 *******
library(dplyr)
library(oce)
library(ggplot2)
## G1
## 1) Input files = .csv version of "I8I9_2007" tab
## from the "CLIVAR_DNALOG_CARLSON2019_with_DNA_ids" file from JM
input.file1 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221217_I8S_I9N_Raw_DNA_ID.csv"
df.raw <- read.csv(input.file1)

unique(df.raw$CAST.TYPE[df.raw$CRUISE=="I8S"])
unique(df.raw$CAST.TYPE[df.raw$CRUISE=="I9N"])
## Per the cast type summary, I8S samples are combination of trace metal and regular casts ("R")
## while I9N samples are all trace metal casts
## 2) Check the range of niskin numbers for I8S and I9N
## I8S TM casts niskins range from 1 - 12: checks out
range(df.raw$NISKIN[df.raw$CRUISE=="I8S"&df.raw$CAST.TYPE=="TRACE METAL"]) 
## I8S R casts niskins range from 23 - 35: makes sense since TM casts don't go beyond 12 
range(df.raw$NISKIN[df.raw$CRUISE=="I8S"&df.raw$CAST.TYPE=="R"])
## I9N all niskins range from: 1 - 12 confirming that it all came from TM casts
range(df.raw$NISKIN[df.raw$CRUISE=="I9N"])

## 3) I08S raw trace metal data downloaded from 
## https://cchdo.ucsd.edu/cruise/33RR20070204 but use modified version 
## with units merged onto the column headers. The TM casts lack almost all relevant data.
input.file2 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221217_I8S_TM_Cast_Modified_YR.csv"
tm.i8.raw <- read.csv(input.file2)

## 4) Subset only the stations used for our samples
tm.i8.relevant <- tm.i8.raw[tm.i8.raw$STNNBR %in% 
                              df.raw$STATION[df.raw$CRUISE=="I8S"&
                                               df.raw$CAST.TYPE=="TRACE METAL"],]

## 5) Since there are no niskin numbers provided in the TM cast data, add niskin numbers 
## counting sequentially from x (e.g., 12) to y (e.g., 1) assuming niskin x is the shallowest
## depth and y is the deepest depth at each station
tm.i8.relevant <- tm.i8.relevant %>% group_by(STNNBR) %>% 
  mutate(Niskin_Assumed = rev(seq_along(STNNBR)))

## 6) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
tm.i8.relevant$Cruise <- "I8S"
## Station - make sure to add leading zeroes so it's two digits 
## so it matches existing DNA_ID
tm.i8.relevant$Station <- paste("S",sprintf("%02d", tm.i8.relevant$STNNBR), sep = "")
## Niskin - have to use the assumed niskin number and cross verify later with depth
tm.i8.relevant$Niskin <- paste("N",sprintf("%02d",tm.i8.relevant$Niskin_Assumed), sep = "")
## Concatenate 
tm.i8.relevant$DNA_ID <- paste(tm.i8.relevant$Cruise, tm.i8.relevant$Station,
                               tm.i8.relevant$Niskin, sep = "-")

## 7) Add SW depth to raw DNA_ID df based on oce package function using pressure (dbar) 
## and latitude (degN = decimal degrees with positive in N hemisphere)
df.raw$Depth <- swDepth(pressure = df.raw$CTDPRS..DBAR., 
                             latitude = df.raw$Latitude..degrees_north.)

## 8) Check calculated SW depth from reported CTD pressures provided by Carlson lab
## against the depth provided in raw TM casts for I8S
tm.i8.relevant$Depth_crosscheck <- df.raw$Depth[match(tm.i8.relevant$DNA_ID,
                                                      df.raw$DNA_ID)]
tm.i8.relevant$Pressure_crosscheck <- df.raw$CTDPRS..DBAR.[match(tm.i8.relevant$DNA_ID,
                                                                 df.raw$DNA_ID)]

## 9) Plot to see how close the reported pressures by Carlson lab are to the depth reported
## in the TM cast data using assumed niskin numbers
ggplot()+
  geom_point(data = tm.i8.relevant, aes(x = DEPTH, y = Depth_crosscheck, color = "Depth"))+
  geom_point(data = tm.i8.relevant, aes(x = DEPTH, y = Pressure_crosscheck, 
                                        color = "Pressure"))+
  ylab("Crosscheck: Depth (m) or Pressure (dBar)")+
  xlab("Reported Depth in TM cast data")
  
## 10) Not fully convinced that the "Depth" reported in the TM cast is actually depth since
## that value is extremely close to the reported "CTDPRS..DBAR." from Carlson lab but it's 
## fair to assume the DNA_ID using assumed niskin numbers are correct so subset I8S TM using
## the DNA_ID.
i8s.tm <- tm.i8.relevant[tm.i8.relevant$DNA_ID %in% 
                           df.raw$DNA_ID[df.raw$CRUISE=="I8S"&
                                           df.raw$CAST.TYPE=="TRACE METAL"],]
range(i8s.tm$Pressure_crosscheck-i8s.tm$DEPTH)
## Discuss with JM and finalize what the true depth (m) to provide as metadata. Since depth
## is never measure with CTD and later calculated, I doubt that the raw TM data is actually
## reporting depth. Thus, I believe their DEPTH column should be CTD.PRS.dBar and 
## we should calculate the depth using OCE package based on this actual reported pressure.
i8s.tm$Actual_Depth <- swDepth(pressure = i8s.tm$DEPTH, 
                               latitude = i8s.tm$LATITUDE)
i8s.tm$Cast_type <- "Trace Metal"
## Subset only the following relevant columns and homogenize the column names
## before merging into sample metadata table for downstream use.
temp <- i8s.tm[,c("DNA_ID","Cruise","Station","Niskin","Cast_type", "LATITUDE", "LONGITUDE", 
                  "DEPTH", "Pressure_crosscheck","Actual_Depth")]
colnames(temp) <- c("DNA_ID","Cruise","Station","Niskin", "Cast_type","Latitude_TM_CTD", 
                    "Longitude_TM_CTD","Pressure_TM_CTD", "Pressure_Carlson","Depth_TM_CTD")

## ** Major issue with I8S TM casts is that the bottle data from R casts don't match up
## with sampled depths so we won't have all metadata. We could at least get CTD Temperature
## and salinity by matching closest pressure to CTD profile but that's also not the most
## complete dataset. ** 

## 11) input file = I08S raw regular (R) cast Bottle data downloaded from 
## https://cchdo.ucsd.edu/cruise/33RR20070204 but use modified version 
## with units merged onto the column headers. 
input.file3 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221217_I8S_R_Cast_Modified_YR.csv")
r.i8.raw <- read.csv(input.file3)

## 12) Subset only the stations used for our samples
r.i8.relevant <- r.i8.raw[r.i8.raw$STNNBR %in% 
                              df.raw$STATION[df.raw$CRUISE=="I8S"&
                                               df.raw$CAST.TYPE=="R"],]

## 13) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
## Cruise - manually input I8S
r.i8.relevant$Cruise <- "I8S"
## Station - make sure to add leading zeroes so it's two digits 
## so it matches existing DNA_ID
r.i8.relevant$Station <- paste("S",sprintf("%02d", r.i8.relevant$STNNBR), sep = "")
## Niskin - assuming analogous column in regular CTD cast is "SAMPNO" b/c "BTLNBR" looks funky
r.i8.relevant$Niskin <- paste("N",sprintf("%02d",r.i8.relevant$SAMPNO), sep = "")
## Concatenate 
r.i8.relevant$DNA_ID <- paste(r.i8.relevant$Cruise, r.i8.relevant$Station,
                             r.i8.relevant$Niskin, sep = "-")

## 14) Subset I8S R using the DNA_ID.
i8s.r <- r.i8.relevant[r.i8.relevant$DNA_ID %in%
                         df.raw$DNA_ID[df.raw$CRUISE=="I8S"&
                                          df.raw$CAST.TYPE=="R"],]
i8s.r$Pressure_crosscheck <- df.raw$CTDPRS..DBAR.[match(i8s.r$DNA_ID,
                                                        df.raw$DNA_ID)]

range(i8s.r$CTDPRS_dbar-i8s.r$Pressure_crosscheck)
i8s.r$Actual_Depth <- swDepth(pressure = i8s.r$CTDPRS_dbar, 
                              latitude = i8s.r$LATITUDE)
## Subset only the following relevant columns and homogenize the column names
## before merging into sample metadata table for downstream use.
i8s.r$Cast_type <- "Regular"
temp2 <- i8s.r[,c("DNA_ID","Cruise","Station","Niskin","Cast_type","DATE", "LATITUDE", "LONGITUDE", 
                  "CTDPRS_dbar", "Pressure_crosscheck","Actual_Depth", "CTDTMP_ITS.90",
                  "CTDSAL_PSS.78","CTDOXY_umol_kg")]
colnames(temp2) <- c("DNA_ID","Cruise","Station","Niskin", "Cast_type","Date_R_CTD","Latitude_R_CTD", 
                     "Longitude_R_CTD","Pressure_R_CTD", "Pressure_Carlson","Depth_R_CTD",
                     "Temperature_R_CTD", "Salinity_R_CTD", "Oxygen_R_CTD")
temp2$Date_Carlson <- df.raw$Date[match(temp2$DNA_ID, df.raw$DNA_ID)]

## 15) input file = I09N raw TM cast data downloaded from 
## https://cchdo.ucsd.edu/cruise/33RR20070322 but use modified version 
## with units merged onto the column headers. 
input.file4 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221217_I9N_TM_Cast_Modified_YR.csv")
tm.i9.raw <- read.csv(input.file4)

## 16) Subset only the stations used for our samples
tm.i9.relevant <- tm.i9.raw[tm.i9.raw$STNNBR %in% 
                              df.raw$STATION[df.raw$CRUISE=="I9N"],]

## 17) Since there are no niskin numbers provided in the TM cast data, add niskin numbers 
## counting sequentially from x (e.g., 12) to y (e.g., 1) assuming niskin x is the shallowest
## depth and x is the deepest depth at each station
tm.i9.relevant <- tm.i9.relevant %>% group_by(STNNBR) %>% 
  mutate(Niskin_Assumed = rev(seq_along(STNNBR)))

## 18) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
tm.i9.relevant$Cruise <- "I9N"
## Station - make sure to add leading zeroes so it's two digits 
## so it matches existing DNA_ID
tm.i9.relevant$Station <- paste("S",sprintf("%02d", tm.i9.relevant$STNNBR), sep = "")
## Niskin - have to use the assumed niskin number and cross verify later with depth
tm.i9.relevant$Niskin <- paste("N",sprintf("%02d",tm.i9.relevant$Niskin_Assumed), sep = "")
## Concatenate 
tm.i9.relevant$DNA_ID <- paste(tm.i9.relevant$Cruise, tm.i9.relevant$Station,
                               tm.i9.relevant$Niskin, sep = "-")

## 19) Check calculated SW depth from reported CTD pressures provided by Carlson lab
## against the depth provided in raw TM casts for I9N
tm.i9.relevant$Depth_crosscheck <- df.raw$Depth[match(tm.i9.relevant$DNA_ID,
                                                      df.raw$DNA_ID)]
tm.i9.relevant$Pressure_crosscheck <- df.raw$CTDPRS..DBAR.[match(tm.i9.relevant$DNA_ID,
                                                                 df.raw$DNA_ID)]

## 20) Plot to see how close the reported pressures by Carlson lab are to the depth reported
## in the TM cast data using assumed niskin numbers
ggplot()+
  geom_point(data = tm.i9.relevant, aes(x = DEPTH_m, y = Depth_crosscheck, color = "Depth"))+
  geom_point(data = tm.i9.relevant, aes(x = DEPTH_m, y = Pressure_crosscheck, 
                                        color = "Pressure"))+
  ylab("Crosscheck: Depth (m) or Pressure (dBar)")+
  xlab("Reported Depth in TM cast data")

## 21) Not fully convinced that the "Depth" reported in the TM cast is actually depth since
## that value is extremely close to the reported "CTDPRS..DBAR." from Carlson lab but it's 
## fair to assume the DNA_ID using assumed niskin numbers are correct so subset I9N TM using
## the DNA_ID.
i9n.tm <- tm.i9.relevant[tm.i9.relevant$DNA_ID %in% 
                           df.raw$DNA_ID[df.raw$CRUISE=="I9N"],]
range((i9n.tm$Pressure_crosscheck-i9n.tm$DEPTH_m), na.rm = T)
## Discuss with JM and finalize what the true depth (m) to provide as metadata. Since depth
## is never measure with CTD and later calculated, I doubt that the raw TM data is actually
## reporting depth. Thus, I believe their DEPTH column should be CTD.PRS.dBar and 
## we should calculate the depth using OCE package based on this actual reported pressure.
i9n.tm$Actual_Depth <- swDepth(pressure = i9n.tm$DEPTH_m, 
                               latitude = i9n.tm$LATITUDE)
i9n.tm$Cast_type <- "Trace Metal"
## Subset only the following relevant columns and homogenize the column names
## before merging into sample metadata table for downstream use.
temp3 <- i9n.tm[,c("DNA_ID","Cruise","Station","Niskin","Cast_type", "LATITUDE", "LONGITUDE", 
                   "DEPTH_m", "Pressure_crosscheck","Actual_Depth")]
colnames(temp3) <- c("DNA_ID","Cruise","Station","Niskin", "Cast_type","Latitude_TM_CTD", 
                     "Longitude_TM_CTD","Pressure_TM_CTD", "Pressure_Carlson","Depth_TM_CTD")

## ** Major issue with I9N TM casts is that the bottle data from R casts don't match up
## with sampled depths so we won't have all metadata. We could at least get CTD Temperature
## and salinity by matching closest pressure to CTD profile but that's also not the most
## complete dataset. ** 

## 22) Merge the I8S and I9N tm casts
i8s.i9n.final <- rbind(temp, temp3)

## 23) Add the dates provided by Carlson lab since there's no TM CTD date
df.raw$Date <- sub("T.*", "", df.raw$yyyy.mm.ddThh.mm)
i8s.i9n.final$Date_Carlson <- df.raw$Date[match(i8s.i9n.final$DNA_ID, df.raw$DNA_ID)]

## 24) Round the TM CTD pressures to the nearest even integer to match with R CTD casts 
## which only have increments of 2 dBar
i8s.i9n.final$Pressure_even <- 2 * round(i8s.i9n.final$Pressure_TM_CTD/2)
## Create StationID by merging cruise and station
i8s.i9n.final$StationID <- paste(i8s.i9n.final$Cruise, i8s.i9n.final$Station, sep = "-")

## 25) input file = merged CTD casts for each of the I8S and I9N stations
input.file5 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221220_I8S_CTD_Cast_Merged.csv")
input.file6 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/20221220_I9N_CTD_Cast_Merged.csv")
ctd.i8s <- read.csv(input.file5)
ctd.i9n <- read.csv(input.file6)

## 26) add dates, latitude, longitude of CTD casts for each unique stationID for I8S and I9N
unique(ctd.i8s$StationID)
ctd.i8s.station <- c("I8S-S11","I8S-S15","I8S-S23","I8S-S32","I8S-S38","I8S-S45","I8S-S48",
                     "I8S-S60","I8S-S70","I8S-S88")
ctd.i8s.dates <- c("20070218","20070219","20070221","20070224","20070226","20070301",
                   "20070301","20070305","20070308","20070313")
ctd.i8s.latitude <- c("-63.2592","-61.4886","-57.9163","-54.7860","-52.2514","-49.2819",
                      "-47.9956","-42.5116","-37.4939","-28.3179")
ctd.i8s.longitude <- c("82.0114","82.0040","82.2286","85.6640","88.3035","91.2198",
                       "92.3522","95.0097","94.9878","95.0084")
ctd.i8s.temp <- data.frame(StationID = ctd.i8s.station, Date_CTD = ctd.i8s.dates,
                           Latitude_CTD = ctd.i8s.latitude, 
                           Longitude_CTD = ctd.i8s.longitude)
ctd.i8s$Date_CTD <- ctd.i8s.temp$Date_CTD[match(ctd.i8s$StationID, 
                                                ctd.i8s.temp$StationID)]
ctd.i8s$Latitude_CTD <- ctd.i8s.temp$Latitude_CTD[match(ctd.i8s$StationID, 
                                                ctd.i8s.temp$StationID)]
ctd.i8s$Longitude_CTD <- ctd.i8s.temp$Longitude_CTD[match(ctd.i8s$StationID, 
                                                ctd.i8s.temp$StationID)]
##
unique(ctd.i9n$StationID)
ctd.i9n.station <- c("I9N-S101","I9N-S107","I9N-S113","I9N-S117","I9N-S125","I9N-S135",
                     "I9N-S145","I9N-S162","I9N-S193","I9N-S198","I9N-S91","I9N-S95")
ctd.i9n.dates <- c("20070330","20070401","20070403","20070404","20070407","20070410",
                   "20070412","20070417","20070425","20070426","20070327","20070328")
ctd.i9n.latitude <- c("-21.3165","-17.9632","-14.6330","-12.4842","-8.2182","-3.1298",
                      "0.0005","6.1198","14.9998","17.5015","-27.1077","-24.7325")
ctd.i9n.longitude <- c("95.0013","95.0027","95.0000","95.0070","95.0003","94.4252",
                       "93.4413","89.6287","89.8498","89.8488","95.0017","95.0140")

ctd.i9n.temp <- data.frame(StationID = ctd.i9n.station, Date_CTD = ctd.i9n.dates,
                           Latitude_CTD = ctd.i9n.latitude, 
                           Longitude_CTD = ctd.i9n.longitude)
ctd.i9n$Date_CTD <- ctd.i9n.temp$Date_CTD[match(ctd.i9n$StationID, 
                                                ctd.i9n.temp$StationID)]
ctd.i9n$Latitude_CTD <- ctd.i9n.temp$Latitude_CTD[match(ctd.i9n$StationID, 
                                                        ctd.i9n.temp$StationID)]
ctd.i9n$Longitude_CTD <- ctd.i9n.temp$Longitude_CTD[match(ctd.i9n$StationID, 
                                                          ctd.i9n.temp$StationID)]

## 27) Add Temperature, salinity, oxygen from even number CTD pressure + stationID
ctd.i8s.i9n <- rbind(ctd.i8s[,c("CTDPRS_DBAR","CTDTMP_ITS.90","CTDSAL_PSS.78",
                                "CTDOXY_UMOL_KG","StationID","Date_CTD","Latitude_CTD",
                                "Longitude_CTD")],
                     ctd.i9n[,c("CTDPRS_DBAR","CTDTMP_ITS.90","CTDSAL_PSS.78",
                                "CTDOXY_UMOL_KG","StationID","Date_CTD","Latitude_CTD",
                                "Longitude_CTD")])
## Concatenate stationID and pressure for merged CTD dataset
ctd.i8s.i9n$StationID_pressure <- paste(ctd.i8s.i9n$StationID, ctd.i8s.i9n$CTDPRS_DBAR,sep = "-")
## Concatenate cruise_station and pressure rounded to closest even integer
i8s.i9n.final$StationID_pressure <- paste(i8s.i9n.final$StationID,
                                          i8s.i9n.final$Pressure_even, sep = "-")
## Add temperature
i8s.i9n.final$Temperature_R_CTD <- ctd.i8s.i9n$CTDTMP_ITS.90[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]
## Add salinity
i8s.i9n.final$Salinity_R_CTD <- ctd.i8s.i9n$CTDSAL_PSS.78[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]
## Add oxygen
i8s.i9n.final$Oxygen_R_CTD <- ctd.i8s.i9n$CTDOXY_UMOL_KG[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]
## Add date
i8s.i9n.final$Date_R_CTD <- ctd.i8s.i9n$Date_CTD[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]
## Add latitude
i8s.i9n.final$Latitude_R_CTD <- ctd.i8s.i9n$Latitude_CTD[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]
## Add longitude
i8s.i9n.final$Longitude_R_CTD <- ctd.i8s.i9n$Longitude_CTD[
  match(i8s.i9n.final$StationID_pressure,ctd.i8s.i9n$StationID_pressure)]

## 28) Cross verify the dates, latitudes, and longitudes
save.df <- i8s.i9n.final[,c("DNA_ID","Cruise","Station","Niskin","Cast_type","Date_Carlson",
                            "Date_R_CTD","Latitude_TM_CTD","Latitude_R_CTD", 
                            "Longitude_TM_CTD","Longitude_R_CTD","Pressure_TM_CTD",
                            "Depth_TM_CTD","Temperature_R_CTD","Salinity_R_CTD",
                            "Oxygen_R_CTD")]


## 29) Final colnames homogenizing of colnames to merge with the I8S R cast data
colnames(save.df) <- c("DNA_ID","Cruise","Station","Niskin","Cast_type","Date_Carlson",
                       "Date_R_CTD","Latitude_Cast_CTD","Latitude_R_CTD", 
                       "Longitude_Cast_CTD","Longitude_R_CTD","Pressure_Cast_CTD",
                       "Depth_Cast_CTD","Temperature_R_CTD","Salinity_R_CTD",
                       "Oxygen_R_CTD")
## the cast latitude, longitude is the same as R_CTD since it all came from regular cast
temp2$Latitude_Cast_CTD <- temp2$Latitude_R_CTD
temp2$Longitude_Cast_CTD <- temp2$Longitude_R_CTD
##
final.i8s.r <- temp2[,c("DNA_ID","Cruise","Station","Niskin","Cast_type","Date_Carlson",
                        "Date_R_CTD","Latitude_Cast_CTD","Latitude_R_CTD", 
                        "Longitude_Cast_CTD","Longitude_R_CTD","Pressure_R_CTD",
                        "Depth_R_CTD","Temperature_R_CTD","Salinity_R_CTD",
                        "Oxygen_R_CTD")]
## change colnames of pressure and depth from "R" to "Cast" designation
colnames(final.i8s.r) <- c("DNA_ID","Cruise","Station","Niskin","Cast_type","Date_Carlson",
                           "Date_R_CTD","Latitude_Cast_CTD","Latitude_R_CTD", 
                           "Longitude_Cast_CTD","Longitude_R_CTD","Pressure_Cast_CTD",
                           "Depth_Cast_CTD","Temperature_R_CTD","Salinity_R_CTD",
                           "Oxygen_R_CTD")
save.df <- rbind(save.df, final.i8s.r)
## 
output.destination <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/I8S_I9N/Data/0.Raw_Data/CSV/")
setwd(output.destination)
write.csv(save.df, file = "1.20221221_I8S_I9N_Sample_Metadata.csv",row.names = F)
