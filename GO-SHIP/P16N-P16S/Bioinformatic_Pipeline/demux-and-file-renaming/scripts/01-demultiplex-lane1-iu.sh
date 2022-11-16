#!/bin/bash -i 

mkdir -p 221011_i7-demux_Lane1-redo

conda activate iu-env 

iu-demultiplex --r1 raw-fastqs/Undetermined_S0_L001_R1_001.fastq.gz --r2 raw-fastqs/Undetermined_S0_L001_R2_001.fastq.gz -i raw-fastqs/Undetermined_S0_L001_I1_001.fastq.gz -o 221011_i7-demux_Lane1-redo -s sample-sheets/barcode_to_sample_lane1.tsv 
