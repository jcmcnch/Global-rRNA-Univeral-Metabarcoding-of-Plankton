## Code Repository for Global rRNA Universal Metabarcoding of Plankton (GRUMP) Project

This repository contains code to reproduce metadata curation and bioinformatic analysis steps used to generate data for the GRUMP project. 

### Metabarcoding data: 

These data will be available in 3 locations and formats:

- **Processed, merged ASV tables** (containing all 16S and 18S amplicon sequences, corrected for observed biases against 18S) will be available on the *Simons Collaborative Marine Atlas Project* (Simons CMAP) website. In this "long" format, each observation of an ASV will be indexed by latitude, longitude, depth, and time. It will also contain some associated metadata where available from collaborators. If you are not sure which data to use, this is probably your best bet. It is, however, a highly redundant data format compared to a traditional ASV table. **Please note that data upload to CMAP is still in progress and will occur after the raw data / processed ASV tables have been uploaded.**
- **Intermediate files from *qiime2* and other parts of the pipeline** will be stored on the Open Science Foundation at https://osf.io/57dpa/ This repository will be useful for people who wish to delve into the data more deeply. For example, if you wanted to look only at a subset of a given dataset (e.g. only 18S/16S/chloroplast/*Archaea*/*Bacteria* sequences) those subsetted ASV tables can be found there. Or perhaps you want to plot some part of this dataset in `phyloseq`. In addition, you can find denoising statistics, `biom` tables, ASV sequences for `BLAST` comparisons, etc.
- **Raw demultiplexed data** will be uploaded to ENA/NCBI. These files *will contain primers* so they need to be trimmed prior to reanalysis. These files would be only needed if you wanted to completely redo any aspects of our analysis from scratch.

### Associated measurements:

Covariates measured alongside the metabarcoding samples will be available in this repository. Since each cruise section will have different data formats and covariates available, we will organize metadata into the subfolders of this repository. The repository contains a record of the intermediate processing steps needed to generate the metadata, as well as links to other relevant repositories.

**The easiest way to access metadata is to follow the links provided in the README files in the subfolders.**
