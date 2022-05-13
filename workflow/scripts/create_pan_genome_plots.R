#!/usr/bin/env Rscript
# Edited copy of a script included in roary package
# Standard way of saving plots ia png() and dev.off() doesn't work
# Here ggsave() and ggplots will be used
# Take the output files from the pan genome pipeline and create nice plots.
library(ggplot2)
library(tidyr)
library(optparse)

# CLI parsing
option_list <- list(
   make_option(c("-i", "--input_directory"),
               type = "character",
               default = NULL,
               help = "A path to a directory with files for plotting produced by Roary",
               metavar = "character"),
   make_option(c("-o", "--output_directory"),
               type="character",
               default=NULL,
               help="A name for output directory (without trailing /)",
               metavar="character"),
   make_option(c("-w", "--fig_width"),
               type = "integer",
               default = 10,
               help="figure width",
               metavar = "integer"),
   make_option(c("-e", "--fig_height"),
               type = "integer",
               default = 6,
               help = "figure height",
               metavar = "integer")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# CLI check
if (is.null(opt$input_directory)){
 print_help(opt_parser)
 stop("A filepath to a directory with input files must be provided", call. = FALSE)
}
if (is.null(opt$output_directory)){
 print_help(opt_parser)
 stop("A filepath to an output directory must be provided", call. = FALSE)
}

# A function to make tidy data nd build a boxplot
# Used for ythe first 4 Rtabs made by ROARY
build_boxplot <- function(df, title){
  # makes a boxplot from roary's data
  # make tidy data
  df_tidy <- gather(df, key="obs", value = "val", 1:ncol(df))
  df_tidy$obs2 <- as.integer(sub("V", "", df_tidy$obs))
  df_tidy$obs2 <- factor(df_tidy$obs2, ordered = T)
  # make a plot
  myplot <- ggplot(df_tidy, aes(obs2, val)) +
    geom_boxplot(outlier.size = 1) +
    theme(axis.text.x = element_text(angle=45, size=6))+
    xlab("No. of genomes") +
    ylab("No. of genes") +
    ggtitle(title)
  return(myplot)
}

# filenames which contain data for boxplots
files_for_boxplots <- c("number_of_new_genes.Rtab", "number_of_conserved_genes.Rtab",
                        "number_of_genes_in_pan_genome.Rtab", "number_of_unique_genes.Rtab")
# make boxplots for tables 1,2,3,4 and save them
for (file in files_for_boxplots){
  basename <- substring(file, 1, nchar(file)-5) # remove extension, to use the rest later
  mydata <- read.table(paste(opt$input_directory, file, sep = "/"), sep="\t")
  mplot <- build_boxplot(df=mydata, title=basename)
  ggsave(paste0(opt$output_directory, "/", basename, ".png"), plot=myplot,
       width=opt$fig_width, height = opt$fig_height, scale=1)
}

# table 5
mydata <- read.table(paste(opt$input_directory, "blast_identity_frequency.Rtab", sep="/"))
# make a barplot
barplot <- ggplot(mydata, aes(V1, V2)) +
  geom_bar(stat="identity") +
  scale_x_continuous(breaks = mydata$V1) +
  xlab("Blast percentage identity") +
  ylab("No. blast results") +
  ggtitle("Number of blastp hits with different percentage identity")
# save
ggsave(filename=paste(opt$output_directory, "blast_identity_frequency.png", sep="/"), plot = barplot,
       width=opt$fig_width, height = opt$fig_height, scale=1)

# Lineplot 1
# read the data
conserved <- colMeans(read.table(paste(opt$input_directory, "number_of_conserved_genes.Rtab", sep="/")))
total <- colMeans(read.table(paste(opt$input_directory, "number_of_genes_in_pan_genome.Rtab", sep="/")))

genes <- data.frame( genes_to_genomes = c(conserved,total),
                    genomes = c(c(1:length(conserved)),c(1:length(conserved))),
                    Key = c(rep("Conserved genes",length(conserved)), rep("Total genes",length(total))) )
# make a plot
lineplot1 <- ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +
  geom_line()+
  ylim(c(1,max(total)))+
  xlim(c(1,length(total)))+
  xlab("No. of genomes") +
  ylab("No. of genes") +
  theme(legend.justification=c(0,1),legend.position=c(0,1))
# save
ggsave(filename=paste(opt$output_directory, "conserved_vs_total_genes.png", sep="/"), plot=lineplot1,
       width=opt$fig_width, height = opt$fig_height, scale=1)

# Lineplot 2
# read the data
unique_genes <- colMeans(read.table(paste(opt$input_directory, "number_of_unique_genes.Rtab", sep="\t")))
new_genes <- colMeans(read.table(paste(opt$input_directory, "number_of_new_genes.Rtab", sep="\t")))
genes <- data.frame( genes_to_genomes = c(unique_genes,new_genes),
                    genomes = c(c(1:length(unique_genes)), c(1:length(unique_genes))),
                    Key = c(rep("Unique genes",length(unique_genes)), rep("New genes", length(new_genes))) )
# make a plot
lineplot2 <- ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +
  geom_line()+
  ylim(c(1,max(unique_genes))) +
  xlim(c(1,length(unique_genes))) +
  xlab("No. of genomes") +
  ylab("No. of genes") +
  theme(legend.justification=c(1,1),legend.position=c(1,0.6))
# save
ggsave(filename=paste(opt$output_directory, "unique_vs_new_genes.png", sep="/"), plot=lineplot2,
       width=opt$fig_width, height = opt$fig_height, scale=1)

# FINAL MESSAGE
print("All done")
