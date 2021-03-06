## OHBM plots
library("data.table")
library("cocor")
library("ggplot2")
library("tidyverse")
library(cowplot)
library(reshape2)
options(stringsAsFactors=FALSE)

# read correlation values
e3=read.csv("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/ohbm/original_corvalues_Mean_Full_SurfArea_BJK.csv")
e3_ancreg=read.csv("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/ohbm/ancestryregressed_corvalues_Mean_Full_SurfArea_BJK.csv")
rep_1=read.csv("/data/clusterfs/lag/users/gokala/enigma-evol/corvals/replication_v1/corvalues_SurfArea_global_total_BJK.csv")
rep_1_ancreg=read.csv("/data/clusterfs/lag/users/gokala/enigma-evol/corvals/ancreg_replication_v1/corvalues_globalValues_averaged_SurfArea_ancreg_BJK.csv")

# read ldsc intercepts
e3_ldsc=read.csv("/data/workspaces/lag/workspaces/lg-neanderthals/raw_data/ENIGMA-EVO/MA6/LDSC/MA6_LDSC_intercepts_before_after_Phase3_ancreg_Rdata_based_noGC.csv")
e3_ldsc=e3_ldsc[e3_ldsc$Surf_Thic=="Surface Area",] # &e3_ldsc$Anc_reg=="TRUE"
e3_ldsc=e3_ldsc[-which(e3_ldsc$Region=="temporalpole"),] # remove temporalpole, because it's not included in the replication study
rep_1_ldsc=read.csv("/data/clusterfs/lag/users/gokala/enigma-evol/ldsc/replication_v1_LDSC_intercepts_w_and_wo_ancreg.csv")
rep_1_ldsc=rep_1_ldsc[rep_1_ldsc$Surf_Thic=="Surface Area",] #&rep_1_ldsc$Anc_reg=="TRUE"
row.names(rep_1_ldsc)=seq(1,nrow(rep_1_ldsc),1)
rep_1_ldsc[rep_1_ldsc$Region=="global",1]="Full"
#rep_1_ldsc=rep_1_ldsc[69:83,]

# read partitioned heritability files
e3_partherit=read.table("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/ohbm/HSE_7pcw_active_merged_results_FDR35.txt",header=T,sep="\t")
e3_partherit=e3_partherit[e3_partherit$Analysis=="Surface Area",]
rep_1_partherit=read.table("/data/clusterfs/lag/users/gokala/enigma-evol/partherit/results_tables/replication_v1/HSE_7pcw_active_merged_results_FDR35.txt",header=T,sep="\t")
rep_1_partherit=rep_1_partherit[rep_1_partherit$Analysis=="Surface Area",]
lr_hemispecCov_partherit=read.table("/data/clusterfs/lag/users/gokala/enigma-evol/partherit/results_tables/regional_hemi_spec_glob/HSE_7pcw_active_merged_results_FDR35.txt",header=T,sep="\t")
lr_globalCov_partherit=read.table("/data/clusterfs/lag/users/gokala/enigma-evol/partherit/results_tables/regional_with_global/HSE_7pcw_active_merged_results_FDR35.txt",header=T,sep="\t")

e3_partherit=e3_partherit[e3_partherit$Analysis=="Surface Area",]
rep_1_partherit=rep_1_partherit[rep_1_partherit$Analysis=="Surface Area",]
merged3=merge(e3_partherit,rep_1_partherit,by="Region")
merged3=merged3[,c("Region","Prop._h2.x","Prop._h2_std_error.x","significant.x","Prop._h2.y","Prop._h2_std_error.y","significant.y")]

###################################################################

##Make barplots of correlation estimates for each
# e3 plot
corind_e3 = grep("BJK_cor",colnames(e3))
pind_e3 = grep("BJK_P",colnames(e3))
seind_e3 = grep("BJK_SE",colnames(e3))
x_e3 = barplot(as.matrix(e3[1,corind_e3]),main=e3$X[1],ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05))
y0_e3 = as.numeric(e3[1,corind_e3]-e3[1,seind_e3])
y1_e3 = as.numeric(e3[1,corind_e3]+e3[1,seind_e3])
arrows(x_e3,y0_e3,x_e3,y1_e3,angle=90,length=0)
bonfsigind_e3 = which(e3[1,pind_e3] < 0.05/20)
nomsigind_e3 = which(e3[1,pind_e3] >= 0.05/20 & e3[1,pind_e3] < 0.05)

# replication 1 (white british subset) plot
corind_rep_1 = grep("BJK_cor",colnames(rep_1))
pind_rep_1 = grep("BJK_P",colnames(rep_1))
seind_rep_1 = grep("BJK_SE",colnames(rep_1))
x_rep_1 = barplot(as.matrix(rep_1[1,corind_rep_1]),main=rep_1$X[1],ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05))
y0_rep_1 = as.numeric(rep_1[1,corind_rep_1]-rep_1[1,seind_rep_1])
y1_rep_1 = as.numeric(rep_1[1,corind_rep_1]+rep_1[1,seind_rep_1])
arrows(x_rep_1,y0_rep_1,x_rep_1,y1_rep_1,angle=90,length=0)
bonfsigind_rep_1 = which(rep_1[1,pind_rep_1] < 0.05/20)
nomsigind_rep_1 = which(rep_1[1,pind_rep_1] >= 0.05/20 & rep_1[1,pind_rep_1] < 0.05)

# E3 results shaded at the back and replication is at the front - plot & save
pdf("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/ohbm/corvalues_e3_vs_replication_darkgray.pdf", width = 8, height = 4)
barplot(as.matrix(e3[1,corind_e3]),col="dark gray",main="Mean Full Surface Area",ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05),border=NA, yaxp = c(-0.05,0.05,2),las=2,cex.names=0.75)
arrows(x_e3,y0_e3,x_e3,y1_e3,col="dark gray",angle=90,length=0)
par(new = TRUE)
barplot(as.matrix(rep_1[1,corind_rep_1]),col="black",ylim=c(-0.05,0.05), yaxp = c(-0.05,0.05,2),las=2, xaxt="n")
arrows(x_rep_1,y0_rep_1,x_rep_1,y1_rep_1,col="black",angle=90,length=0)
text(x_e3[bonfsigind_e3],col="dark gray",0.045,"*")
text(x_e3[nomsigind_e3],col="dark gray",0.045,"o")
text(x_rep_1[bonfsigind_rep_1],col="black",0.040,"*")
text(x_rep_1[nomsigind_rep_1],col="black",0.040,"o")
dev.off()

### Same plot for ancestry regressed sumstats

# e3 plot
corind_e3_ancreg = grep("BJK_cor",colnames(e3_ancreg))
pind_e3_ancreg = grep("BJK_P",colnames(e3_ancreg))
seind_e3_ancreg = grep("BJK_SE",colnames(e3_ancreg))
x_e3_ancreg = barplot(as.matrix(e3_ancreg[1,corind_e3_ancreg]),main=e3_ancreg$X[1],ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05))
y0_e3_ancreg = as.numeric(e3_ancreg[1,corind_e3_ancreg]-e3_ancreg[1,seind_e3_ancreg])
y1_e3_ancreg = as.numeric(e3_ancreg[1,corind_e3_ancreg]+e3_ancreg[1,seind_e3_ancreg])
arrows(x_e3_ancreg,y0_e3_ancreg,x_e3_ancreg,y1_e3_ancreg,angle=90,length=0)
bonfsigind_e3_ancreg = which(e3_ancreg[1,pind_e3_ancreg] < 0.05/20)
nomsigind_e3_ancreg = which(e3_ancreg[1,pind_e3_ancreg] >= 0.05/20 & e3_ancreg[1,pind_e3_ancreg] < 0.05)

# replication 1 (white british subset) plot
corind_rep_1_ancreg = grep("BJK_cor",colnames(rep_1_ancreg))
pind_rep_1_ancreg = grep("BJK_P",colnames(rep_1_ancreg))
seind_rep_1_ancreg = grep("BJK_SE",colnames(rep_1_ancreg))
x_rep_1_ancreg = barplot(as.matrix(rep_1_ancreg[1,corind_rep_1_ancreg]),main=rep_1_ancreg$X[1],ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05))
y0_rep_1_ancreg = as.numeric(rep_1_ancreg[1,corind_rep_1_ancreg]-rep_1_ancreg[1,seind_rep_1_ancreg])
y1_rep_1_ancreg = as.numeric(rep_1_ancreg[1,corind_rep_1_ancreg]+rep_1_ancreg[1,seind_rep_1_ancreg])
arrows(x_rep_1_ancreg,y0_rep_1_ancreg,x_rep_1_ancreg,y1_rep_1_ancreg,angle=90,length=0)
bonfsigind_rep_1_ancreg = which(rep_1_ancreg[1,pind_rep_1_ancreg] < 0.05/20)
nomsigind_rep_1_ancreg = which(rep_1_ancreg[1,pind_rep_1_ancreg] >= 0.05/20 & rep_1_ancreg[1,pind_rep_1_ancreg] < 0.05)

pdf("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/ohbm/ancreg_corvalues_e3_vs_replication_darkgray.pdf", width = 8, height = 4)
barplot(as.matrix(e3_ancreg[1,corind_e3_ancreg]),col="dark gray",main="Mean Full Surface Area",ylab="correlation coefficient",xlab="Ancestry PC",names.arg=paste0("PC",seq(1,20)),ylim=c(-0.05,0.05),border=NA, yaxp = c(-0.05,0.05,2),las=2,cex.names=0.75)
arrows(x_e3_ancreg,y0_e3_ancreg,x_e3_ancreg,y1_e3_ancreg,col="dark gray",angle=90,length=0)
par(new = TRUE)
barplot(as.matrix(rep_1_ancreg[1,corind_rep_1_ancreg]),col="black",ylim=c(-0.05,0.05), yaxp = c(-0.05,0.05,2),las=2, xaxt="n")
arrows(x_rep_1_ancreg,y0_rep_1_ancreg,x_rep_1_ancreg,y1_rep_1_ancreg,col="black",angle=90,length=0)
dev.off()

###################################################################

# Run a correlation test btw. E3 and replication correlation values and see if they are significantly different
merged=rbind(e3,rep_1)[,corind_rep_1]
row.names(merged)=e3$X
merged_transpose <- transpose(merged)
rownames(merged_transpose) <- colnames(merged)
colnames(merged_transpose) <- rownames(merged)

## Correlation of correlations? doesn't work
cocor(~Mean_Full_SurfArea + SurfArea_global_total | Mean_Full_SurfArea + SurfArea_global_total, merged_transpose,
      alternative = "two.sided", test = "all",
      na.action = getOption("na.action"), alpha = 0.05, conf.level = 0.95,
      null.value = 0, return.htest = FALSE)

###################################################################

## LDSC comparison plots
e3_ldsc = e3_ldsc[c(which(e3_ldsc$Region=="Full"),which(e3_ldsc$Region!="Full")),] # move Full to the top
my.order = seq(1,136,1)
e3_ldsc$sample="Tilot et al. 2020"
rep_1_ldsc$sample="UKB replication"
merged2=rbind(e3_ldsc,rep_1_ldsc)

ggplot(merged2, aes(fct_rev(reorder(Region,my.order)), LDSC_intercept,color=Anc_reg)) + 
  geom_errorbar(aes(ymax = LDSC_intercept + LDSC_int_sterr,  ymin = LDSC_intercept - LDSC_int_sterr), position = position_dodge(0.9),width=0) +
  geom_point(position = position_dodge(0.9), size = 2) + facet_grid(. ~ sample) +
  scale_color_manual(name = "Ancestry regression", labels = c("Prior to ancestry regression","After ancestry regression"),values=c("#af8dc3", "#7fbf7b")) +
  background_grid(major = 'y', minor = "none") + # add thin horizontal lines 
  labs(y = "LDSC Intercept", 
       x = "Region", 
       title = "Changes in LDSC intercept due to ancestry regression") + 
  panel_border() + coord_flip() + geom_hline(yintercept = 1, linetype="dotted", 
                                               color = "black", size=0.5) +
  theme(plot.title = element_text(hjust = 0.5))
ggsave("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/plots/e3_rep_LDSC_intercepts_before_after_ancreg_w_errorbars_surfaceArea_v2.pdf", width = 7, height = 9, unit = "in")

###################################################################

## Partitioned heritability comparison plots
regionordering <- read.csv("/data/workspaces/lag/workspaces/lg-neanderthals/raw_data/ENIGMA-EVO/MA6/Cerebral_Cortex_revisions/plotting/freesurfer_orderandcolor.csv")
merged3$Region = factor(merged3$Region, levels = regionordering$Region)
merged3 = merged3[c(which(merged3$Region=="Full"),which(merged3$Region!="Full")),] # move Full to the top

# Asterisks
y_max <- max(merged3[,c(2,5)])
y_axis_max <- y_max + merged3[merged3$Prop._h2.y==y_max, 5] + 0.02
label.df.x <- data.frame(Region = merged3$Region[merged3$significant.x=="Yes"],Prop._h2.x=merged3$Prop._h2.x[merged3$significant.x=="Yes"]+0.07)
label.df.y <- data.frame(Region = merged3$Region[merged3$significant.y=="Yes"],Prop._h2.y=merged3$Prop._h2.y[merged3$significant.y=="Yes"]+0.09)
colnames(label.df.y)[2]="Prop._h2.x"

ggplot(data = merged3, aes(Region, Prop._h2.x)) +
  geom_bar(stat = "identity", position = "dodge", fill = "dark gray") +
  geom_linerange(position = position_dodge(width = 0.9), aes(ymin = Prop._h2.x - Prop._h2_std_error.x, ymax = Prop._h2.x + Prop._h2_std_error.x),color="dark gray") +
  geom_bar(data=merged3, aes(Region, Prop._h2.y), stat = "identity", position = "dodge", fill = "burlywood4") +
  geom_linerange(position = position_dodge(width = 0.9), aes(ymin = Prop._h2.y - Prop._h2_std_error.y, ymax = Prop._h2.y + Prop._h2_std_error.y),color="burlywood4") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = "bottom") +
  labs(x = "Region", y = expression(paste("Prop. ", italic("h"^{2}))),
    title = "Partitioned heritability for cortical surface area, following ancestry regression",
    subtitle = "Proportion of heritability explained") +
  geom_text(data = label.df.x, label = "*", col="dark gray") +
  geom_text(data = label.df.y, label = "*", col="burlywood4")
ggsave("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/plots/e3_rep_partherit_w_errorbars_surfaceArea_darkgray.pdf", width = 9, height = 6, unit = "in")


ggplot(data = results[results$Analysis == "Surface Area", ], mapping = aes(Region, Prop._h2)) +
  geom_bar(stat = "identity", position = "dodge", fill = "burlywood4") +
  geom_linerange(position = position_dodge(width = 0.9), aes(ymin = Prop._h2 - Prop._h2_std_error, ymax = Prop._h2 + Prop._h2_std_error)) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = "bottom") +
  labs(
    x = "Region",
    y = expression(paste("Prop. ", italic("h"^{
      2
    }))),
    title = "Partitioned heritability for cortical surface area, following ancestry regression",
    subtitle = "Proportion of heritability explained"
  )

# Enrichment plot
regionordering <- read.csv("/data/workspaces/lag/workspaces/lg-neanderthals/raw_data/ENIGMA-EVO/MA6/Cerebral_Cortex_revisions/plotting/freesurfer_orderandcolor.csv")
rep_1_partherit$Region = factor(rep_1_partherit$Region, levels = regionordering$Region)
rep_1_partherit = rep_1_partherit[c(which(rep_1_partherit$Region=="Full"),which(rep_1_partherit$Region!="Full")),] # move Full to the top
my.order = seq(1,34,1)
row.names(rep_1_partherit)=my.order
annot <- unique(rep_1_partherit$Annotation)
ggplot(data = rep_1_partherit, mapping = aes(Region, Enrichment))+
  geom_bar(stat="identity", position = "dodge", fill = "saddlebrown")+
  geom_linerange(position = position_dodge(width = 0.9), aes(ymin=Enrichment-Enrichment_std_error, ymax=Enrichment+Enrichment_std_error))+
  geom_text(aes(x = Region, y = Enrichment+(Enrichment_std_error+2), label = annot.p), position = position_dodge(width = 0.9), size = 3,  fontface=3, hjust = 0, vjust = 0, angle = 45)+
  theme_classic()+
  theme(axis.text = element_text(angle = 45, hjust = 1))+
  labs(x = "Region", 
       y = "Enrichment", 
       title = annot)
ggsave("/data/workspaces/lag/workspaces/lg-ukbiobank/projects/enigma_evol/enigma_evo/evol-pipeline/plots/rep1_partherit_enrichment_w_errorbars_surfaceArea.pdf", width = 9, height = 6, unit = "in")