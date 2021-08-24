#!/bin/bash

#### Demultiplexing and clone filtering of 3RAD datasets using STACKS.

#### As written, assumes STACKS is installed and in Path.

##Split 96 well plates using i7 indexes. If using NovaSeq 6000, i7 index is in leftmost index in fasta header, and it’s a reverse complement of oligo used in library prep. Trimming to 150 in this step, assuming sequencing was done with 2 x 150bp, and extra bp not removed by sequencing facility.

mkdir plateSplit
process_radtags -1 BrookFloater_July2021_S1_L001_R1_001.fastq.gz -2 BrookFloater_July2021_S1_L001_R2_001.fastq.gz -b BrookFloater_plateBarcodes.txt -o plateSplit --rescue --index_null --retain_header --disable_rad_check -t 150

##Concatenate samples from each plate (in this example, four i7 indexes were used per plate). Output file format will depend on names in above barcode file, so may need to change below commands accordingly.
cd plateSplit

zcat Plate1_[1-4].1.fq.gz >Plate1_R1.fq
zcat Plate1_[1-4].2.fq.gz >Plate1_R2.fq
zcat Plate2_[1-4].1.fq.gz >Plate2_R1.fq
zcat Plate2_[1-4].2.fq.gz >Plate2_R2.fq

##Can use gzip, but pigs is MUCH faster. -p is number of cores to use
pigz -p 10 Plate1_R1.fq
pigz -p 10 Plate1_R2.fq
pigz -p 10 Plate2_R1.fq
pigz -p 10 Plate2_R2.fq

##Remove intermediate files
rm Plate1_[1-4].1.fq.gz
rm Plate1_[1-4].2.fq.gz
rm Plate2_[1-4].1.fq.gz
rm Plate2_[1-4].2.fq.gz

## Split samples using the inline barcodes. Be sure to specifc the enxzyme you used in library prep. 
#Can also add -D to keep discarded reads, but take up space

#Plate 1
mkdir BrookFloater_Plate1
process_radtags -1 Plate1_R1.fastq.gz -2 Plate1_R2.fastq.gz -b Plate1_barcodes.txt -o BrookFloater_Plate1 -q -r --inline_inline --renz_1 xbaI --renz_2 ecoRI --filter_illumina --retain_header

#Plate 2
mkdir BrookFloater_Plate2
process_radtags -1 Plate2_R1.fastq.gz -2 Plate2_R2.fastq.gz -b Plate2_barcodes.txt -o BrookFloater_Plate2 -q -r --inline_inline --renz_1 xbaI --renz_2 ecoRI --filter_illumina --retain_header

####Clone Filter
cd BrookFloater_Plate1
cloneFilterBatch.sh ##assumes script is in your path
cd ../BrookFloater_Plate2
cloneFilterBatch.sh
