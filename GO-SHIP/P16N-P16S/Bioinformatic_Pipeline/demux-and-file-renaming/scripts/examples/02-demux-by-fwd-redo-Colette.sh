#!/bin/bash -i
conda activate cutadapt-env 

indir=00-adapter-fastas-Colette-redemux
outdir=211018_demux-redo-Colette
mkdir -p $outdir

for item in $indir/* ; do 

	filestem=`basename $item .fasta`  
	R1=`ls Rindices-Colette/$filestem*R1*`
	R2=`ls Rindices-Colette/$filestem*R2*`

	#multithreaded support not possible as of yet for demultiplexing, still stupid fast compared to qiime1
	cutadapt -e 0 --no-indels --cores 1 \
	-g file:$item -o $outdir/{name}.R1.fastq.gz \
	-p $outdir/{name}.R2.fastq.gz $R1 $R2

done 

conda deactivate
