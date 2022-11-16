#!/bin/bash -i
conda activate cutadapt-env 

for item in sample-sheets/generate-fastas-for-cutadapt-Lane2/output/* ; do 

	filestem=`basename $item .fasta`  
	R1=`ls 220202_i7-demux_Lane2/$filestem*R1*`
	R2=`ls 220202_i7-demux_Lane2/$filestem*R2*`

	#multithreaded support not possible as of yet for demultiplexing, still stupid fast compared to qiime1
	cutadapt -e 0 --no-indels --cores 1 \
	-g file:$item -o 220202_final-tag-demux_Lane2/{name}.R1.fastq.gz \
	-p 220202_final-tag-demux_Lane2/{name}.R2.fastq.gz $R1 $R2

done 

conda deactivate
