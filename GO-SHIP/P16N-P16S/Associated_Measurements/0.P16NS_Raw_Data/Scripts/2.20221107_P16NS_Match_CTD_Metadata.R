## 2022-11-18: G1 - Add columns of CTD data from tracemetal (TM) casts
## or regular (reg) casts for samples corresponding to the corrected DNA_ID
## G2 - Add [DNA] and photic zone designations to the P16 N/S sample metadata
## Note - *** We need to still verify units for all these measurements as 
## they are from different CTD casts ***

## G1
## 1) Input files = corrected DNA ID and cast type file
input.file1 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/1.20221107_P16NS_Confirmed_DNA_ID_Cast_Type.csv"
dna.id <- read.csv(input.file1)

## 2) Subset by TM and reg casts
df.tm <- dna.id[dna.id$Cast_Type=="Trace_Metal",]
df.reg <- dna.id[dna.id$Cast_Type=="Regular_Cast",]

## 3) Merged P16 S and N trace metal cast CTD data for which the source needs to 
## be determined - check notes and document here ____________________ !!! ***
input.file2 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/P16_Tracemetal_Cast_Source_Temp.csv"
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
                 "CTDPRS","TEMPERATURE","SALNTY","OXYGEN","PHSPHT",
                 "SILCAT","NITRAT","NITRIT")
df.tm.merged <- merge(x = df.tm[,c("Original_DNA_ID", "Cast_Type", 
                                   "Corrected_DNA_ID")], 
                      y = df.tm.raw[,tm.raw.cols], by.x = "Corrected_DNA_ID",
                      by.y = "DNA_ID")

## 6) P16S regular casts CTD data for which the source needs to 
## be determined - check notes and document here ____________________ !!! ***
input.file3 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/P16S_Easier_to_navigate_YR_20211025_Source_Temp.csv")
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
                 "CTDPRS","CTDTMP","SALNTY","OXYGEN","PHSPHT",
                 "SILCAT","NITRAT","NITRIT")
df.reg.merged <- merge(x = df.reg[,c("Original_DNA_ID", "Cast_Type", 
                                   "Corrected_DNA_ID")], 
                      y = p16s.reg.raw[,reg.raw.cols], by.x = "Corrected_DNA_ID",
                      by.y = "DNA_ID")

## 9 Homogenize the colnames to merge into one df
colnames(df.tm.merged) <- c("Corrected_DNA_ID","Original_DNA_ID","Cast_Type",
                            "Cruise","Station","Niskin","Latitude","Longitude",
                            "Pressure","Temperature","Salinity","Oxygen",          
                            "Phosphate","Silicate","Nitrate","Nitrite" )
colnames(df.reg.merged) <- c("Corrected_DNA_ID","Original_DNA_ID","Cast_Type",
                            "Cruise","Station","Niskin","Latitude","Longitude",
                            "Pressure","Temperature","Salinity","Oxygen",          
                            "Phosphate","Silicate","Nitrate","Nitrite" )
p16ns.metadata <- rbind(df.tm.merged, df.reg.merged)

##G2
## 1) input file = manual photic zone binning done by JM and YR
input.file4 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/20221028_P16NS_Euphotic_Zone_Manual_Binning_Done_YR.csv")
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
input.file5 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/TSV/221116_P16N-S_DNA_concentrations_for_CMAP.tsv")
dna.con <- read.csv(input.file5, sep = "\t", header = T)

## 8) Add [DNA] column matching to original DNA_ID
p16ns.final$DNA.concentration.ng.uL <- dna.con$DNA.extract.concentration..ng.µL.[
  match(p16ns.final$Original_DNA_ID, dna.con$Original_SampleID)]

## 9) Add SW depth based on oce package function using pressure (dbar) 
## and latitude (degN = decimal degrees with positive in N hemisphere)
library(oce)
p16ns.final$Depth <- swDepth(pressure = p16ns.final$Pressure, 
                             latitude = p16ns.final$Latitude)

## 10) Save output file
output.file <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/")
setwd(output.file)
write.csv(p16ns.final, file = "2.20221118_P16NS_Sample_Metadata_Final.csv", row.names = F)
