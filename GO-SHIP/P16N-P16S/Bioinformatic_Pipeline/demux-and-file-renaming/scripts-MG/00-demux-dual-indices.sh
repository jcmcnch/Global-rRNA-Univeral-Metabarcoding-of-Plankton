#!/bin/bash
source activate bcl2fastq-env

mkdir -p /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/220815_demuxd_MG 

#run with sample sheet according to NEB website
bcl2fastq \
 --sample-sheet /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/sample-sheets/220815_sample_sheet_220202_HiSeq_RapidRun.csv \
 -i /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-basecalls/220128_D00780_0514_BHN73WBCX3/Data/Intensities/BaseCalls/ \
 -R /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-basecalls/220128_D00780_0514_BHN73WBCX3/ \
 -o /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/220815_demuxd_MG \
 -r 20 \
 -p 20 \
 -w 32 \
 --barcode-mismatches 0

conda deactivate
