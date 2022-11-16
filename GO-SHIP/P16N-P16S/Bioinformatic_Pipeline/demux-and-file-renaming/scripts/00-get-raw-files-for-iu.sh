#!/bin/bash
source activate bcl2fastq-env

mkdir -p /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-fastqs/

#run with no sample sheet input
bcl2fastq \
 -i /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-basecalls/220128_D00780_0514_BHN73WBCX3/Data/Intensities/BaseCalls/ \
 -R /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-basecalls/220128_D00780_0514_BHN73WBCX3/ \
 -o /home/jesse/TuftsTUCF/220202_HiSeq_RapidRun_2x250/raw-fastqs/ \
 -r 20 \
 -p 20 \
 -w 32 \
 --create-fastq-for-index-reads \
 --barcode-mismatches 0

conda deactivate
