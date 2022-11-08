## Code Repository for Global Universal Metabarcoding of Plankton (GUMP) Project

This repository contains code necessary for reproducing metadata curation and bioinformatic analyses associated with the GUMP project. The final data will be available in 3 locations and formats:

- **Processed, merged ASV tables** (containing all 16S and 18S amplicon sequences, corrected for observed biases against 18S) will be available on the *Simons Collaborative Marine Atlas Project* (Simons CMAP) website. If you are not sure which data to use, this is probably your best bet.
- **Intermediate files from *qiime2* and other parts of the pipeline** will be stored on the Open Science Foundation at https://osf.io/57dpa/ This repository will be useful for people who wish to delve into the data more deeply. For example, if you wanted to look only at a subset of a given dataset (e.g. only 18S/16S/chloroplast/*Archaea*/*Bacteria* sequences) those subsetted ASV tables can be found there. In addition, you can find denoising statistics, `biom` tables, ASV sequences for `BLAST` comparisons, etc.
- **Raw demultiplexed data** will be uploaded to ENA/NCBI. These files *will contain primers* so they need to be trimmed prior to reanalysis. This would be only needed if you wanted to completely redo any aspects of our analysis from scratch.
