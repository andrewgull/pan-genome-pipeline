from Bio import SeqIO

embl = SeqIO.read("results/pangenome/core_alignment_header.embl", "embl")
# features contain start and stop for each gene in core_gene_alignment
print(embl.features)
