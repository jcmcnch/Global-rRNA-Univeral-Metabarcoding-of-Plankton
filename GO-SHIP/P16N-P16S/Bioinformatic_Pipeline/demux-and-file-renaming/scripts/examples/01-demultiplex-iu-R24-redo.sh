#!/bin/bash -i 

conda activate iu-env 

mkdir -p 210909_demultiplexed-R24_redo

iu-demultiplex --r1 JMSNRSCF_S1_L001_R1_001.fastq.gz --r2 JMSNRSCF_S1_L001_R2_001.fastq.gz -i JMSNRSCF_S1_L001_I1_001.fastq.gz -o 210909_demultiplexed-R24_redo -s barcode_to_sample_lane1-R24-corrected.tsv 
