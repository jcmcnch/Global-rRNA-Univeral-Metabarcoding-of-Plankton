#!/bin/bash -i

for item in *.R1.fastq.gz ; do 
	
	samplename=`echo $item | sed 's/.R1.fastq.gz//'`
	libraryname=GRUMP_$samplename
	R1=$item
	R2=`ls $samplename*R2.fastq.gz`
	printf "$samplename\t$libraryname\t$R1\t$R2\n"

done
