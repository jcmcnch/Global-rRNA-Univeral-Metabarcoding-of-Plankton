## 2022-11-04: G1 - Identify any potential mismatches with DNA ID 
## supplied by the Carlson Lab
## G2 - Resolve discrepancies identified 
## G3 - Create output file with confirmed DNA_IDs and Cast type 

## G1
## 1) Input files = .csv version of tabs "P16S_2005" and "P16N_2006"
## from the "CLIVAR_DNALOG_CARLSON2019_with_DNA_ids" file from JM
## P16S tab excludes Station 09
input.file1 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/20221104_P16S_Raw_DNA_ID.csv"
df.s <- read.csv(input.file1)
## Subset P16S with relevant overlapping columns 
df.s <- df.s[,c("DNA_ID","CRUISE","STATION","NISKIN",
                "Latitude..degrees_north.","Longitude..degrees_east.",
                "CTDPRS..DBAR.")]
colnames(df.s) <- c("DNA_ID", "Cruise", "Station", "Niskin", 
                    "Latitude_degrees_N","Longitude_degrees_E", 
                    "CTD_Pressue_dbar")
## P16N tab excludes Station 02
input.file2 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/20221104_P16N_Raw_DNA_ID.csv"
df.n <- read.csv(input.file2)
## Subset P16N with relevant overlapping columns 
df.n <- df.n[,c("DNA_ID","CRUISE","STATION","NISKIN",
                "Latitude..degrees_north.","Longitude..degrees_east.",
                "CTDPRS.DBARS.")]
colnames(df.n) <- c("DNA_ID", "Cruise", "Station", "Niskin", 
                    "Latitude_degrees_N","Longitude_degrees_E", 
                    "CTD_Pressue_dbar")
## 2) Merge the P16 S and N transects 
p16sn.raw <- rbind(df.s,df.n)
## 3) Per the notes on "SAMPLE SUMMARY" tab on the raw .xlsx file, all samples 
## were taken from Trace Metals Cast so add that as cast type column
p16sn.raw$Cast_Type <- "Trace_Metal"
## 4) Merged P16 S and N trace metal cast CTD data for which the source needs to 
## be determined - check notes and document here ____________________ !!! ***
input.file3 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/P16_Tracemetal_Cast_Source_Temp.csv"
df.tm.raw <- read.csv(input.file3)
## 5) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
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
## 6) Add CTD pressure from trace metal casts
p16sn.raw$TM_Pressure <- df.tm.raw$CTDPRS[match(p16sn.raw$DNA_ID, 
                                                df.tm.raw$DNA_ID)]
## 7) If NAs exist, replace with constant of -100
p16sn.raw$TM_Pressure <- ifelse(is.na(p16sn.raw$TM_Pressure), -100,
                                p16sn.raw$TM_Pressure)
## 8) Calculate absolute difference between the two pressures
p16sn.raw$Difference <- abs(p16sn.raw$CTD_Pressue_dbar-p16sn.raw$TM_Pressure)
## 9) Compare the pressure reported for each sample with unique DNA_ID with 
## corresponding pressure from the associated trace metal cast
## Plot  
library(ggplot2)
p1 <- ggplot()+
  geom_point(data = p16sn.raw, aes(x = CTD_Pressue_dbar, y = TM_Pressure,
                                   color = Cruise))+
  geom_point(data = p16sn.raw[p16sn.raw$Difference > 10,], 
             aes(x = CTD_Pressue_dbar, y = TM_Pressure), shape = 1,
             size = 3)+
  geom_text(data = p16sn.raw[p16sn.raw$Difference > 10,],
            aes(x = CTD_Pressue_dbar, y = TM_Pressure,
                label = DNA_ID), hjust = 0.5, vjust = -1)+
  theme_minimal()
p1

## G2
## All the problem stations where discrepancies occur are along the P16S transect
## Problem cluster 1: At fixed pressure -100 along y-axis (TM_Pressure)
## This suggests that these samples did not in fact come from the trace metal
## 1) Identify the range of Niskin numbers from problem cluster 1
range(p16sn.raw$Niskin[p16sn.raw$Difference > 10]) ## 8 - 36
## 2) Identify the range of Niskin numbers from TM casts
range(df.tm.raw$Niskin) ## N01 - N15
## Since the Niskin numbers range from 8 - 36, we can definitively conclude
## that they could not have all come trace metal casts, which range from 1 -15
## 3) P16S regular casts CTD data for which the source needs to 
## be determined - check notes and document here ____________________ !!! ***
input.file4 <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/P16S_Easier_to_navigate_YR_20211025_Source_Temp.csv")
p16s.reg.raw <- read.csv(input.file4)
## 4) Concatenate Cruise, Station, and Niskin analogous columns to produce DNA_ID
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
## 5) Add CTD pressure from regular casts
p16sn.raw$Reg_Pressure <- p16s.reg.raw$CTDPRS[match(p16sn.raw$DNA_ID, 
                                                    p16s.reg.raw$DNA_ID)]
## 6) Create new pressure column that's a combination of TM and Reg casts
p16sn.raw$TM_Reg_Pressure <- ifelse(p16sn.raw$TM_Pressure == -100, 
                                    p16sn.raw$Reg_Pressure, 
                                    p16sn.raw$TM_Pressure)
p16sn.raw$Cast_Type <- ifelse(p16sn.raw$TM_Pressure == -100,
                              "Regular_Cast", p16sn.raw$Cast_Type)
## 7) Calculate new absolute difference between the original pressure and 
## pressure derived from either TM or Reg CTD cast
p16sn.raw$Difference2 <- abs(p16sn.raw$CTD_Pressue_dbar-p16sn.raw$TM_Reg_Pressure)
## 8) Compare the pressure reported for each sample with unique DNA_ID with 
## corresponding pressure from the associated TM or reg cast
p2 <- ggplot()+
  geom_point(data = p16sn.raw, aes(x = CTD_Pressue_dbar, y = TM_Reg_Pressure,
                                   color = Cruise))+
  geom_point(data = p16sn.raw[p16sn.raw$Difference2 > 10,], 
             aes(x = CTD_Pressue_dbar, y = TM_Reg_Pressure), shape = 1,
             size = 3)+
  geom_text(data = p16sn.raw[p16sn.raw$Difference2 > 10,],
            aes(x = CTD_Pressue_dbar, y = TM_Reg_Pressure,
                label = DNA_ID), hjust = 0.5, vjust = -1)+
  theme_minimal()
p2
## Problem cluster 2: remnant problem samples from S47 which are from TM cast
p16s.47 <- p16sn.raw[p16sn.raw$Cruise=="P16S"&p16sn.raw$Station==47,]
p16s.47.raw <- df.tm.raw[df.tm.raw$Cruise=="P16S"&df.tm.raw$Station=="S47",
                         c("DNA_ID","CTDPRS")]
## Add the recorded pressures to compare more easily
p16s.47.raw$Manual_Record_Pressure <- p16s.47$CTD_Pressue_dbar[
  match(p16s.47.raw$DNA_ID, p16s.47$DNA_ID )]
## In this situation, we weren't sure whether the recorded DNA_IDs (Niskin #)
## or the recorded pressures were correct.
## JM/YR - plot [DNA] to figure out that their recorded pressures are correct
## 9) Plot DNA depth profiles for P16S-S47
input.file5 <- "/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/TSV/20221026_P16NS_DNA_Conc_sample-metadata_JM.tsv"
dna <- read.csv(input.file5, sep = "\t", header = T)
dna$Sect_ID <- trimws(dna$Sect_ID, "l")
dna.16s47 <- dna[dna$Sect_ID=="P16S"&dna$Station_number==47,]
p3 <- ggplot(data = dna.16s47, aes(x = DNA_extract_conc_ng.µL, y = Pressure))+
  geom_point()+
  geom_line(orientation = "y")+
  scale_y_reverse()+
  theme_minimal()
p3
## The plot output doesn't follow a Martin curve distribution currently with
## mismatched DNA IDs.
## 10) Manually change the pressure to match the correct Niskin ID
## N08
dna.16s47$Pressure_Manual_Curate <- ifelse(dna.16s47$SampleID=="P16S-S47-N08", 
    p16s.47.raw$CTDPRS[p16s.47.raw$DNA_ID=="P16S-S47-N14"],
    dna.16s47$Pressure)
## N14
dna.16s47$Pressure_Manual_Curate <- ifelse(dna.16s47$SampleID=="P16S-S47-N14", 
    p16s.47.raw$CTDPRS[p16s.47.raw$DNA_ID=="P16S-S47-N08"],
    dna.16s47$Pressure_Manual_Curate)
## N15
dna.16s47$Pressure_Manual_Curate <- ifelse(dna.16s47$SampleID=="P16S-S47-N15", 
    p16s.47.raw$CTDPRS[p16s.47.raw$DNA_ID=="P16S-S47-N05"],
    dna.16s47$Pressure_Manual_Curate)
## Re-plot
p3.1 <- ggplot(data = dna.16s47, aes(x = DNA_extract_conc_ng.µL, y = Pressure_Manual_Curate))+
  geom_point()+
  geom_line(orientation = "y")+
  scale_y_reverse()+
  theme_minimal()
p3.1
## If you put the CTD pressures for the correct DNA_ID
## the plot follows a Martin curve distribution.
## Conclusion for P16S-S47: the manual recorded target pressures are reliable
## and what's incorrect is their recorded Niskin IDs.
## P16S-S47-N14 should be called P16S-S47-N08
## P16S-S47-N08 should be called P16S-S47-N14
## P16S-S47-N15 should be called P16S-S47-N05
## JM will change these DNA_IDs to accurately reflect the confirmed changes.
## 11) Manually change it here
p16sn.raw$DNA_ID_Confirmed <- p16sn.raw$DNA_ID
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S47-N14",
                           "P16S-S47-N08", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S47-N08",
                        "P16S-S47-N14", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S47-N15",
           "P16S-S47-N05", p16sn.raw$DNA_ID_Confirmed)

## Problem cluster 3: newly identified samples from S84 which are
## from Reg CTD cast
p16s.84 <- p16sn.raw[p16sn.raw$Cruise=="P16S"&p16sn.raw$Station==84,]
p16s.84.raw <- p16s.reg.raw[p16s.reg.raw$Station=="S84",
                            c("DNA_ID","CTDPRS")]
p16s.84.raw$Manual_Record_Pressure <- p16s.84$CTD_Pressue_dbar[
  match(p16s.84.raw$DNA_ID, p16s.84$DNA_ID )]
## I think another case of incorrect DNA_IDs so if we correct the 
## Niskin numbers based off the recorded target pressures, we will have a much
## better fit between recorded pressures and CTD pressure from corresponding
## regular CTD cast data. It looks like a simple row transposition error
## N27 --> N26, N26 --> N25, N24 --> N23, N22 --> N21, N20 --> N19
## 12) Manually change the DNA_IDs
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S84-N27",
                   "P16S-S84-N26", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S84-N26",
                   "P16S-S84-N25", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S84-N24",
                   "P16S-S84-N23", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S84-N22",
                  "P16S-S84-N21", p16sn.raw$DNA_ID_Confirmed)
p16sn.raw$DNA_ID_Confirmed <- ifelse(p16sn.raw$DNA_ID=="P16S-S84-N20",
                  "P16S-S84-N19", p16sn.raw$DNA_ID_Confirmed)

## G3
## 1) Subset p16sn.raw
p16ns.curate <- p16sn.raw[,c("DNA_ID","DNA_ID_Confirmed", "Cast_Type")]
## 2) Save output file
colnames(p16ns.curate) <- c("Original_DNA_ID", "Corrected_DNA_ID", "Cast_Type")
output.file <- c("/Users/yubinraut/Documents/Fuhrman_Lab/CBIOMES_Biogeography/Major_PFT_Manuscript/Data/0.P16NS_Raw_Data/CSV/")
setwd(output.file)
write.csv(p16ns.curate, file = "1.20221107_P16NS_Confirmed_DNA_ID_Cast_Type.csv", row.names = F)
