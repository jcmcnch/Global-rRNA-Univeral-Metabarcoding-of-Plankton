## 2023-05-30: G1 - Add columns of CTD data from tracemetal (TM) casts
## or regular (reg) casts for samples corresponding to the corrected DNA_ID
## G2 - Add [DNA] and photic zone designations to the P16 N/S sample metadata
## Note - *** We need to still verify units for all these measurements as 
## they are from different CTD casts ***
library(ggplot2)
## G1
## 1) Input files = corrected DNA ID and cast type file
input.file1 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Data/0.P16NS_Raw_Data/1.20230530_P16NS_Confirmed_DNA_ID_Cast_Type.csv"
dna.id <- read.csv(input.file1)

## 2) Subset by TM and reg casts
df.tm <- dna.id[dna.id$Cast_Type=="Trace_Metal",]
df.reg <- dna.id[dna.id$Cast_Type=="Regular_Cast",]

## 3) Merged P16 S and N trace metal cast CTD data downloaded from BCO-DMO
## http://data.bco-dmo.org/jg/info/BCO/CLIVAR_AEROSOL/P16_Trace_Metal_Profiles%7Bdir=data.bco-dmo.org/jg/dir/BCO/CLIVAR_AEROSOL/,data=data.bco-dmo.org:80/jg/serv/BCO/CLIVAR_AEROSOL/P16_trace_metal_profiles.html0%7D?
input.file2 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Source_Files/P16NS_CTD_Casts/P16NS_Tracemetal_Cast_BCO_DMO.csv"
df.tm.raw <- read.csv(input.file2)

## 4) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
## Cruise
df.tm.raw$Cruise <- sub("^([^_]*)_([^_]*).*", "\\1", df.tm.raw$EXPOCODE)
## Station - make sure to add leading zeroes so it's two digits 
## so it matches existing DNA_ID
df.tm.raw$Station <- paste("S",sprintf("%02d", df.tm.raw$STNNBR), sep = "")
## Niskin - assuming analogous column in trace metal CTD cast is "SAMPNO"
df.tm.raw$Niskin <- paste("N",sprintf("%02d",df.tm.raw$SAMPNO), sep = "")
## Concatenate 
df.tm.raw$DNA_ID <- paste(df.tm.raw$Cruise, df.tm.raw$Station,
                          df.tm.raw$Niskin, sep = "-")

## 5) Subset TM CTD casts by corrected DNA_ID 
## list of columns to merge from CTD data
tm.raw.cols <- c("DNA_ID","Cruise","Station","Niskin","latitude","longitude",
                 "DATE","CTDPRS","TEMPERATURE","SALNTY","OXYGEN","PHSPHT",
                 "SILCAT","NITRAT","NITRIT")
df.tm.merged <- merge(x = df.tm[,c("Original_DNA_ID","Corrected_DNA_ID","Cast_Type")], 
                      y = df.tm.raw[,tm.raw.cols], by.x = "Corrected_DNA_ID",
                      by.y = "DNA_ID")

## 3) P16S regular casts CTD data: National Centers for Environmental Information - NOAA
## https://www.ncei.noaa.gov/access/ocean-carbon-acidification-data-system/oceans/ndp_090/
input.file3 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Source_Files/P16NS_CTD_Casts/P16S_Easier_to_navigate_YR_20211025_NCEI_NOAA.csv")
p16s.reg.raw <- read.csv(input.file3)

## 7) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
## Cruise - make sure to trim leading whitespace
p16s.reg.raw$Cruise <- trimws(p16s.reg.raw$SECT_ID, "l")
## Station - make sure to add leading zeroes so it's two digits 
## so it matches existing DNA_ID
p16s.reg.raw$Station <- paste("S",sprintf("%02d", p16s.reg.raw$STNNBR), sep = "")
## Niskin - assuming analogous column in regular CTD cast is "SAMPNO" or "BTLNBR"
p16s.reg.raw$Niskin <- paste("N",sprintf("%02d",p16s.reg.raw$SAMPNO), sep = "")
## Concatenate 
p16s.reg.raw$DNA_ID <- paste(p16s.reg.raw$Cruise, p16s.reg.raw$Station,
                             p16s.reg.raw$Niskin, sep = "-")

## 8) Subset reg CTD casts by corrected DNA_ID 
## list of columns to merge from CTD data
reg.raw.cols <- c("DNA_ID","Cruise","Station","Niskin","LATITUDE","LONGITUDE",
                 "DATE","CTDPRS","CTDTMP","SALNTY","OXYGEN","PHSPHT",
                 "SILCAT","NITRAT","NITRIT")
df.reg.merged <- merge(x = df.reg[,c("Original_DNA_ID","Corrected_DNA_ID", "Cast_Type")], 
                      y = p16s.reg.raw[,reg.raw.cols], by.x = "Corrected_DNA_ID",
                      by.y = "DNA_ID")

## 9 Homogenize the colnames to merge into one df
colnames(df.tm.merged) <- c("Corrected_DNA_ID","Original_DNA_ID","Cast_Type",
                            "Cruise","Station","Niskin","Latitude","Longitude",
                            "Date","Pressure","Temperature","Salinity","Oxygen",          
                            "Phosphate","Silicate","Nitrate","Nitrite")
colnames(df.reg.merged) <- c("Corrected_DNA_ID","Original_DNA_ID","Cast_Type",
                            "Cruise","Station","Niskin","Latitude","Longitude",
                            "Date","Pressure","Temperature","Salinity","Oxygen",          
                            "Phosphate","Silicate","Nitrate","Nitrite")
p16ns.metadata <- rbind(df.tm.merged, df.reg.merged)

##G2
## 1) input file = manual photic zone binning done by JM and YR
input.file4 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Source_Files/P16NS_Extra_Files/20221028_P16NS_Euphotic_Zone_Manual_Binning_Done_YR.csv")
photic <- read.csv(input.file4)

## 2) Add photic zone by matching with original DNA_ID
p16ns.metadata$Photic.Zone <- photic$Zone[match(p16ns.metadata$Original_DNA_ID,
                                                photic$DNA_ID)]

## 3) Count how many samples don't have a photic designation
sum(is.na(p16ns.metadata$Photic.Zone)) ## 9 samples

## 4) For samples from P16N-S47, you need a separate matching DNA_ID
photic$DNA_ID2 <- gsub("(^P16N-S47-N[0-9]{2}).*", "\\1", photic$DNA_ID)

## 5) Add photic bin for these P16N-S47 samples
p16ns.metadata$Photic.Zone <- ifelse(is.na(p16ns.metadata$Photic.Zone),
                                     photic$Zone[match(
                                       p16ns.metadata$Original_DNA_ID,
                                       photic$DNA_ID2)], 
                                     p16ns.metadata$Photic.Zone)
sum(is.na(p16ns.metadata$Photic.Zone)) ## 3 samples left

## 6) Manually remove these 3 samples since all 3 were confirmed with JM to 
## have insufficient sequencing coverage (< 5,000 reads/sample) and are 
## excluded from out dataset
p16ns.metadata$Original_DNA_ID[is.na(p16ns.metadata$Photic.Zone)]
samples.exclude <- c("P16N-S26-N08","P16N-S40-N01","P16N-S61-N06")
p16ns.final <- p16ns.metadata[!p16ns.metadata$Original_DNA_ID 
                              %in% samples.exclude,]
sum(is.na(p16ns.final$Photic.Zone)) ## 0 samples left

## 7) input file = [DNA]
input.file5 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Source_Files/P16NS_Extra_Files/221116_P16N-S_DNA_concentrations_for_CMAP.tsv")
dna.con <- read.csv(input.file5, sep = "\t", header = T)

## 8) Add [DNA] column matching to original DNA_ID
p16ns.final$DNA.concentration.ng.uL <- dna.con$DNA.extract.concentration..ng.µL.[
  match(p16ns.final$Original_DNA_ID, dna.con$Original_SampleID)]

## 9) Add SW depth based on oce package function using pressure (dbar) 
## and latitude (degN = decimal degrees with positive in N hemisphere)
library(oce)
p16ns.final$Depth <- swDepth(pressure = p16ns.final$Pressure, 
                             latitude = p16ns.final$Latitude)

## 10) Only include the corrected DNA IDs and moving forward, this is all that will be used
p16ns.final2 <- p16ns.final[,c(1,3:20)]

## 11) Change colnames to include units
colnames(p16ns.final2) <- c("DNA_ID","Cast_Type","Cruise","Station","Niskin",
                            "Latitude.degrees.North", "Longitude.degrees.East",
                            "Date.yyyy.mm.dd", "Pressure.decibars", 
                            "Temperature.degrees.Celsius", "Salinity.psu",
                            "Oxygen.umol.kg", "Phosphate.umol.kg", "Silicate.umol.kg",
                            "Nitrate.umol.kg", "Nitrite.umol.kg", "Photic.Zone",
                            "DNA.concentration.ng.uL","Depth.meters")

## 12) Plot the DNA concentrations for each unique station to see if it follows 
## Martic curve distribution
dna.plot <- p16ns.final2
dna.plot$Facet <- paste(dna.plot$Cruise, dna.plot$Station, sep = "_")
dna.plot <- dna.plot[order(-dna.plot$Pressure.decibars),]
ggplot(dna.plot, aes(x = DNA.concentration.ng.uL, y = Pressure.decibars))+
  geom_point()+
  geom_path()+
  scale_y_reverse()+
  facet_wrap(~Facet)
# dna.plot[dna.plot$Facet=="P16S_S84", c("DNA_ID", "Pressure.decibars", "DNA.concentration.ng.uL")]

## 13) Add time to final output of TM casts
p16ns.final2$Time.Trace.Metal.Cast <- ifelse(p16ns.final2$Cast_Type=="Trace_Metal",
                                             df.tm.raw$time[match(p16ns.final2$DNA_ID, df.tm.raw$DNA_ID)],
                                             "Regular Cast")


## 13.1) Add time (in a different format) from Regular casts to final df
p16ns.final2$Time.Regular.Cast <-  ifelse(p16ns.final2$Cast_Type=="Regular_Cast",
                                          p16s.reg.raw$TIME[match(p16ns.final2$DNA_ID,p16s.reg.raw$DNA_ID)],
                                                            "TM Cast")

## 14) Save output file
output.file <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/P16NS/Data/0.P16NS_Raw_Data/")
setwd(output.file)
write.csv(p16ns.final2, file = "2.20230603_P16NS_Sample_Metadata_Final-timeofsampling.csv", row.names = F, quote = F)
