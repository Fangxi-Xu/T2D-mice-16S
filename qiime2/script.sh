#!/bin/bash
#
#SBATCH --job-name=sweet
#SBATCH --nodes=1 --ntasks-per-node=8
#SBATCH --time=100:00:00   # HH/MM/SS
#SBATCH --output=sweet.out
#SBATCH --mem=64G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=fx363@nyu.edu

module purge

WORK=/scratch/fx363/sweet_mice_16s
LOG=$WORK/QIIME_log_$TM.txt

#This IS QIIME2 VERSION 2021.11.0
#import data to qiime2
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools import \
#  --type SampleData[PairedEndSequencesWithQuality] \
#  --input-path $WORK/fastqs \
#  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
#  --output-path sequences.qza

#demultiplexing summary
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime demux summarize \
#  --i-data sequences.qza \
#  --o-visualization demux.qzv

#dada2 
#echo script begin: $(date)
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime dada2 denoise-paired \
#  --i-demultiplexed-seqs sequences.qza \
#  --p-trunc-len-f 270 \
#  --p-trunc-len-r 239 \
#  --p-trim-left-f 17 \
#  --p-trim-left-r 21 \
#  --o-table table.qza \
#  --o-representative-sequences rep-seqs.qza \
#  --o-denoising-stats denoising-stats.qza
#echo script complete: $(date)

#Summarise and visualise DADA2 results
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-table summarize \
#  --i-table table.qza \
#  --o-visualization table.qzv \
#  --m-sample-metadata-file sweet_mice_mapping_file.txt

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-table tabulate-seqs \
#  --i-data rep-seqs.qza \
#  --o-visualization rep-seqs.qzv

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime metadata tabulate \
#  --m-input-file denoising-stats.qza \
#  --o-visualization denoising-stats.qzv

#Create a phylogenetic tree
/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

#export tree file to nwk format
/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools export \
  --input-path rooted-tree.qza \
  --output-path exported_tree_rooted

#test the classifier
/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-classifier classify-sklearn \
 --i-classifier silva-138-ssu-nr99-341f-805r-classifier.qza \
 --i-reads rep-seqs.qza \
 --o-classification taxonomy.qza

/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime metadata tabulate \
 --m-input-file taxonomy.qza \
 --o-visualization taxonomy.qzv

#taxa barplot
/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime taxa barplot \
--i-table table.qza \
--i-taxonomy taxonomy.qza \
--m-metadata-file sweet_mice_mapping_file.txt \
--o-visualization taxa-bar-plots.qzv

/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools export \
--input-path table.qza \
--output-path biom_table

cd biom_table
/scratch/work/public/singularity/run-qiime2-2021.11.0.bash biom convert -i feature-table.biom -o feature-table.tsv --to-tsv

