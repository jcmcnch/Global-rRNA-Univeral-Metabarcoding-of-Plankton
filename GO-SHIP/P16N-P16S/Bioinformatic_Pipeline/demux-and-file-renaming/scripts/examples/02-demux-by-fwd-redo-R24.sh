#!/bin/bash -i
conda activate cutadapt-env 

for item in 00-adapter-fastas-R24/* ; do 

	filestem=`basename $item .fasta`  
	R1=`ls 210909_demultiplexed-R24_redo/$filestem*R1*`
	R2=`ls 210909_demultiplexed-R24_redo/$filestem*R2*`

	#multithreaded support not possible as of yet for demultiplexing, still stupid fast compared to qiime1
	cutadapt -e 0 --no-indels --cores 1 \
	-g file:$item -o 210910_demultiplexed-R24/{name}.R1.fastq.gz \
	-p 210910_demultiplexed-R24/{name}.R2.fastq.gz $R1 $R2

done 

conda deactivate
