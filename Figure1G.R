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

#barplot - selected genera
#prepare dataset
phylo.prop = transform_sample_counts(phylo, function(x) (x / sum(x))*100 )

#barplot
phylo.selected <- subset_taxa(phylo.prop, Genus == "Bacteroides"|Genus == "Prevotellaceae_UCG-001")
phylo.selected
glom_g <- tax_glom(phylo.selected, taxrank = 'Genus')
data_g <- psmelt(glom_g) # create dataframe from phyloseq object
g.melt <- reshape2::melt(data_g)

g_summary <-g.melt %>%
  group_by(Group,Genus) %>%  # the grouping variable
  summarise(mean_Abun = mean(value),# calculates the mean of each group
            sd_Abun = sd(value), # calculates the standard deviation of each group
            n_Abun = n(),  # calculates the sample size per group
            SE_Abun = sd(value)/sqrt(n()))# calculates the standard error of each group


p <- ggplot(g_summary, aes(fill=Genus, y=mean_Abun, x=Group)) + 
  scale_fill_manual(values = c( "WT"="#ADE292", "MKR_Sham"="#905FD0"))+
  ylab("Mean Relative Abundance(%)") +
  facet_wrap(~Genus,scales = "free", ncol = 4) +
  geom_bar(aes(color=Group,fill=Group),stat="identity",color="black",width=0.5)+
  geom_errorbar(aes(ymin=mean_Abun,ymax=mean_Abun+SE_Abun),width=.2) +
  theme(strip.background = element_rect(fill=NULL,linetype="blank"), #facet background
        strip.text.x = element_text(size=14,face = "bold"))+#facet font size
  theme(strip.background = element_blank())

pdf("Figure1G.pdf", width = 6, height =3)
p
dev.off()
