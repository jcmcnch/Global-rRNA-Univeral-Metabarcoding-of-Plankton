#!/bin/bash
source activate bcl2fastq-env

bcl2fastq \
 -i /data/korriban/raw_data_unlocked/run061_HiSeq_USC_gradients-biogeotraces-spotUCYNA-PTR3/190913_D00156_0423_AHVJCTBCX2/Data/Intensities/BaseCalls/ \
 -R /data/korriban/raw_data_unlocked/run061_HiSeq_USC_gradients-biogeotraces-spotUCYNA-PTR3/190913_D00156_0423_AHVJCTBCX2/ \
 -o /data/korriban/raw_data_unlocked/run061_HiSeq_USC_gradients-biogeotraces-spotUCYNA-PTR3/190923_demux_round1 \
 --sample-sheet /data/korriban/raw_data_unlocked/run061_HiSeq_USC_gradients-biogeotraces-spotUCYNA-PTR3/info/190923_demux_sample_sheet.csv \
 -r 20 \
 -p 20 \
 -w 32 \
 --barcode-mismatches 0

conda deactivate
