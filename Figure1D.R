#R version 4.2.2 (2022-10-31)
####################
#load phyloseq object
phylo <- readRDS("myphyloseq.rds")
#load required library
library("phyloseq")
library("microViz")
library("pheatmap")
library("dplyr")
library("rstatix")
library("data.table")
library(tidyr)
library(ggplot2)

#############################################################
#heatmap - Genus Level
#prepare dataset
phylo.prop = transform_sample_counts(phylo, function(x) (x / sum(x))*100 )
genus_glom <- tax_glom(phylo.prop, taxrank = "Genus")#agglomerate at the genus taxonomic rank 
genus<-psmelt(genus_glom)# melt phyloseq object into large data frame
genus = subset(genus, select = c("Sample","Genus","Abundance"))#select columns to use; put value variable at the end
#merge duplicated rows
genus%>%
  group_by(Sample, Genus) %>%
  summarise_all(sum) %>%
  data.frame() -> genus_agg

genus_reshape <- reshape2::dcast(genus_agg, Sample ~ Genus, value.var='Abundance') #transform data
genus_reshape <- genus_reshape %>% remove_rownames %>% column_to_rownames(var="Sample")#column "Sample" to row name
genus_reshape_t <- as.data.frame(t(genus_reshape))
genus_reshape_t$sum <- rowSums(genus_reshape_t)

new_genus_reshape <- genus_reshape_t[order(-genus_reshape_t$sum),]

top20 <- new_genus_reshape[1:20,]
top20 <- top20[,-c(14)]
#transpose the df and keep the sampleIDs as the header
options(scipen=999)
top20_t <- as.data.frame(t(top20))

#prepare annotation 
ann <- data.frame(sample_data(phylo.prop))
ann <- ann[order(ann$Group),]
ann$Group <- as.character(ann$Group)
ann <- ann[,1:3, drop=FALSE]
genus_reshape_top20_ordered <- top20_t[rownames(ann), ]#reorder matrix based on annotation

genus_top20_ordered_zscore <- scale(genus_reshape_top20_ordered)#Z score transformation
summary(genus_top20_ordered_zscore)
#sample based heatmap - z-score normalized
ann_colors = list(Group = c("WT"="#ADE292", "MKR_Sham"="#905FD0"),
                  Week = c("W9"="#fdfd96", "W13"="#f0e68c"),
                  Depletion = c("Before_Depletion"="#dcd0ff"))#specify colors for annotation
p<-pheatmap(t(genus_top20_ordered_zscore), scale = "row", color = colorRampPalette(c("#27408B","#3a60cd","white", "#e60000","#cd0000"))(50), 
             cellheight = 11,
             cellwidth = 8,
             fontsize_row=10, 
             fontsize_col=4, 
             show_colnames = T,show_rownames = T, annotation_col = ann, annotation_colors = ann_colors,
             angle_col = "45",  cluster_cols = F,border_color=NA)

p
pdf("Figure1D.pdf", width = 8, height =6)
p
dev.off()


