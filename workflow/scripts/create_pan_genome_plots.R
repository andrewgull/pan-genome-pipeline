#!/usr/bin/env Rscript
# Edited copy of a script included in roary package
# ABSTRACT: Create R plots
# PODNAME: create_plots.R
# Take the output files from the pan genome pipeline and create nice plots.
library(ggplot2)
library(optparse)

# CLI parsing
option_list <- list(
   make_option(c("-i", "--input_directory"),
               type = "character",
               default = "pangenome",
               help = "A path to a directory with files for plotting produced by Roary",
               metavar = "character"),
   make_option(c("-o", "--output_directory"),
               type="character",
               default="plots",
               help="A name for output directory",
               metavar="character"),
   make_option(c("-w", "--fig_width"),
               type = "integer",
               default = 1414,
               help="figure width",
               metavar = "integer"),
   make_option(c("-h", "--fig_height"),
               type = "integer",
               default = 790,
               help = "figure height",
               metavar = "integer")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Read in data, make a plot, save to a file
# table 1
mydata <- read.table(paste(opt$input_directory, "number_of_new_genes.Rtab", sep="/"))

png(paste(opt$output_directory, "number_of_new_genes.png", sep="/"), width=1414, height = 790)
boxplot(mydata, data=mydata, main="Number of new genes",
         xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
dev.off()

# table 2
mydata <- read.table(paste(opt$input_directory, "number_of_conserved_genes.Rtab", sep="/"))

png(paste(opt$output_directory, "number_of_conserved_genes.png", sep="/"), width=1414, height = 790)
boxplot(mydata, data=mydata, main="Number of conserved genes",
          xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
dev.off()

# table 3
mydata <- read.table(paste(opt$input_directory, "number_of_genes_in_pan_genome.Rtab", sep="/"))

png(paste(opt$output_directory, "number_of_genes_in_pan_genome.png", sep="/"), width=1414, height = 790)
boxplot(mydata, data=mydata, main="No. of genes in the pan-genome",
          xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
dev.off()

# table 4
mydata <- read.table(paste(opt$input_directory, "number_of_unique_genes.Rtab", sep="/"))

png(paste(opt$output_directory, "number_of_unique_genes.png", sep="/"), width=1414, height = 790)
boxplot(mydata, data=mydata, main="Number of unique genes",
         xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
dev.off()

# table 5
mydata <- read.table(paste(opt$input_directory, "blast_identity_frequency.Rtab", sep="/"))

png(paste(opt$output_directory, "blast_identity_frequency.png", sep="/"), width=1414, height = 790)
plot(mydata,main="Number of blastp hits with different percentage identity",  xlab="Blast percentage identity", ylab="No. blast results")
dev.off()

# ggplot figure 1
conserved <- colMeans(read.table(paste(opt$input_directory, "number_of_conserved_genes.Rtab", sep="/")))
total <- colMeans(read.table(paste(opt$input_directory, "number_of_genes_in_pan_genome.Rtab", sep="/")))

genes <- data.frame( genes_to_genomes = c(conserved,total),
                    genomes = c(c(1:length(conserved)),c(1:length(conserved))),
                    Key = c(rep("Conserved genes",length(conserved)), rep("Total genes",length(total))) )
                    
ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +
  geom_line()+
  theme_classic() +
  ylim(c(1,max(total)))+
  xlim(c(1,length(total)))+
  xlab("No. of genomes") +
  ylab("No. of genes") +
  theme_bw(base_size = 16) +
  theme(legend.justification=c(0,1),legend.position=c(0,1))

ggsave(filename=paste(opt$output_directory, "conserved_vs_total_genes.png", sep="/"), scale=1)

# ggplot figure 2

unique_genes <- colMeans(read.table(paste(opt$input_directory, "number_of_unique_genes.Rtab", sep="/")))
new_genes <- colMeans(read.table(paste(opt$input_directory, "number_of_new_genes.Rtab", sep="/")))

genes <- data.frame( genes_to_genomes = c(unique_genes,new_genes),
                    genomes = c(c(1:length(unique_genes)), c(1:length(unique_genes))),
                    Key = c(rep("Unique genes",length(unique_genes)), rep("New genes", length(new_genes))) )
                    
ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +
  geom_line()+
  theme_classic() +
  ylim(c(1,max(unique_genes))) +
  xlim(c(1,length(unique_genes))) +
  xlab("No. of genomes") +
  ylab("No. of genes") +
  theme_bw(base_size = 16) +
  theme(legend.justification=c(1,1),legend.position=c(1,1))

  ggsave(filename=paste(opt$output_directory, "unique_vs_new_genes.png", sep="/"), scale=1)

print("All done")
