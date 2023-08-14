#R version 4.2.2 (2022-10-31)
####################
#load phyloseq object
phylo <- readRDS("myphyloseq.rds")
#load required libraries
library(phyloseq)
library(BiodiversityR)
library(rstatix)
library(microbiome)
library(ggpubr)
library(tidyverse)
library(microViz)
library(ggordiplots)
#################################################################################
#Bray-Curtis Beta diversity
sample_data(phylo)$Group <- factor(sample_data(phylo)$Group)
is.factor(sample_data(phylo)$Group)
levels(sample_data(phylo)$Group)
# Change the order of levels
sample_data(phylo)$Group <- factor(sample_data(phylo)$Group, 
                                                levels = c("WT","MKR_Sham"), labels = c("NG","HG"))
sample_data(phylo)$Group

set.seed(5)
dist <- phyloseq::distance(phylo, method = "bray")
perma <- adonis2(dist~Group, data = as(sample_data(phylo), "data.frame"), permutations = 999)
perma


bray1 <- ordinate(phylo, "PCoA", "bray")


group.colors <- c("NG"="#ADE292", "HG"="#905FD0")
group.shapes <- c("NG"=15, "HG"=16)

bray2 <- plot_ordination(phylo, 
                         bray1, color="Group", shape = "Group") + 
  stat_ellipse(geom = "polygon", type="norm", linewidth=1, alpha=0.2, aes(color=Group, fill=Group))+
  scale_fill_manual(values = group.colors)+
  scale_color_manual(values = group.colors)+
  scale_shape_manual(values = group.shapes)+
  ggtitle("Bray-Curtis") + geom_point(size = 6)

pdf("Figure1C.pdf",width=5,height=4)
bray2
dev.off()
