#!/bin/bash -i 

mkdir -p 220202_i7-demux_Lane2

conda activate iu-env 

iu-demultiplex --r1 raw-fastqs/Undetermined_S0_L002_R1_001.fastq.gz --r2 raw-fastqs/Undetermined_S0_L002_R2_001.fastq.gz -i raw-fastqs/Undetermined_S0_L002_I1_001.fastq.gz -o 220202_i7-demux_Lane2 -s sample-sheets/barcode_to_sample_lane2.tsv 
