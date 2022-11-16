#!/usr/bin/env python3

import csv
import sys

hashBarcodes = {}

#make dictionary of sequences with anchoring character at beginning
for astrLine in csv.reader(open(sys.argv[1]), csv.excel_tab):
	
	hashBarcodes[astrLine[0].strip()] = astrLine[1].strip()

#now read in your sample info. third column should match the sample name you provided to bcl2fastq so you can easily automate the whole process in a shell script
for astrLine in csv.reader(open(sys.argv[2]), csv.excel_tab):

	if astrLine[2]:
		
		filestem=astrLine[2]
		outfile="output/" + astrLine[2] + ".fasta"

	with open(outfile, "a+") as output_file:
		
		output_file.write(">" + astrLine[0] + "\n")
		output_file.write(hashBarcodes[astrLine[1]] + "\n")
