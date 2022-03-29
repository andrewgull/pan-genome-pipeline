# this script si intended to rename and join separate files into one in fasta directory
# output should be written to resources/genomes

import glob

data_path = "/home/andrei/Data/Pan_genome/fasta"

strain_files = glob.glob(data_path + "/*")

# for each item in strain_files
# if item one file: copy it ot resources/genomes and change name to dir name
# else: join files and send them to resources/genomes, name should be the same as directory's name


