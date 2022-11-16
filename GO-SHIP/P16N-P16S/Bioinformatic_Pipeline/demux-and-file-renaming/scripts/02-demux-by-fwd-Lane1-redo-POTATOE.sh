#!/bin/bash -i
conda activate cutadapt-env 

mkdir -p 221014_final-tag-demux_Lane1-POTATOE-AMT-redo

for item in sample-sheets/generate-fastas-for-cutadapt-Lane1/output/CAP* ; do 

	filestem=`basename $item .fasta`  
	R1=`ls 221011_i7-demux_Lane1-redo/$filestem*R1*`
	R2=`ls 221011_i7-demux_Lane1-redo/$filestem*R2*`

	#multithreaded support not possible as of yet for demultiplexing, still stupid fast compared to qiime1
	cutadapt -e 0 --no-indels --cores 1 \
	-g file:$item -o 221014_final-tag-demux_Lane1-POTATOE-AMT-redo/{name}.R1.fastq.gz \
	-p 221014_final-tag-demux_Lane1-POTATOE-AMT-redo/{name}.R2.fastq.gz $R1 $R2

done 

conda deactivate
