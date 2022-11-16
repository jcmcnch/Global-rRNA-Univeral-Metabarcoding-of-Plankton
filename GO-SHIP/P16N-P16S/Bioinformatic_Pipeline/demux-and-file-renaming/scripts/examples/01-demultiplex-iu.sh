#!/bin/bash -i 

conda activate iu-env 

iu-demultiplex --r1 JMSNRSCF_S1_L001_R1_001.fastq.gz --r2 JMSNRSCF_S1_L001_R2_001.fastq.gz -i JMSNRSCF_S1_L001_I1_001.fastq.gz -o 210908_demultiplexed -s barcode_to_sample_lane1.tsv
