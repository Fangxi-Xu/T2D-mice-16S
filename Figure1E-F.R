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

####################################
genus_glom <- tax_glom(phylo, taxrank = "Genus")#agglomerate at the genus taxonomic rank 
library(MicrobiotaProcess)
diffres <- diff_analysis(obj=genus_glom, #a phyloseq object
                         classgroup="Group",#the factor name in sampledata
                         subclass=NULL,#no subclass compare
                         standard_method=NULL,#the relative abundance of taxonomy will be used
                         mlfun="lda",
                         firstcomfun = "kruskal.test",
                         padjust="fdr",
                         filtermod="pvalue",
                         firstalpha=0.05,
                         strictmod=TRUE,
                         clwilc=TRUE, 
                         subclwilc=FALSE,
                         lda=3)
diffres

plotes <- ggeffectsize(obj=diffres,
                       pointsize=3,
                       linecolor="grey",
                       linewidth=1,
                       lineheight=0.4,
                       removeUnknown=TRUE) + scale_color_manual(values=c("WT"="#ADE292", "MKR_Sham"="#905FD0"))+
  theme(axis.text.x=element_text(size=8, color = "black"))+
  theme(axis.title.x=element_text(size=8, color = "black"))+
  theme(axis.title.y=element_text(size=8, color = "black"))+
  theme(axis.text.y=element_text(size=8, color = "black"))+
  theme(legend.title=element_text(size=12, color = "black"), 
        legend.text=element_text(size=12,  color = "black"),
        axis.text.y=element_text(size=5, color="black"),
        strip.text = element_blank(),
        legend.position="bottom")

pdf("Figure1E.pdf", width=7,height=5)
plotes
dev.off()


diffcladeplot <- ggdiffclade(obj=diffres,#diffAnalysisClass Object2
                             alpha=0.4, size=0.8, 
                             skpointsize=0.8,
                             taxlevel=6,
                             cladetext=2,
                             settheme=FALSE, 
                             setColors=FALSE,
                             removeUnknown=FALSE) +
  scale_fill_manual(values=c("WT"="#ADE292", "MKR_Sham"="#905FD0"))+
  guides(color = guide_legend(keywidth = 0.2,
                              keyheight = 0.6,
                              order = 3, 
                              ncol=1)) + 
  theme(panel.background=element_rect(fill=NA),
        legend.position="right",
        plot.margin=margin(0,0,0,0),
        legend.spacing.y = unit(0.02, "cm"),
        legend.title=element_text(size=8),
        legend.text=element_text(size=6),
        legend.box.spacing=unit(0.01,"cm")
  )
pdf("Figure1F.pdf", width=8,height=6)
diffcladeplot
dev.off()
