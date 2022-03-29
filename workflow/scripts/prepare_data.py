# this script si intended to rename and join separate files into one in fasta directory
# output should be written to resources/genomes

import glob
import shutil
from Bio import SeqIO
from tqdm import tqdm


data_path = "/home/andrei/Data/Pan_genome/fasta"
destination = "/home/andrei/Data/Pan_genome/resources/genomes"
strain_files = glob.glob(data_path + "/*")

# for each item in strain_files
# if item one file: copy it ot resources/genomes and change name to dir name
# else: join files and send them to resources/genomes, name should be the same as directory's name

for item in tqdm(strain_files):
    fasta_files = glob.glob(item + "/*.fa")
    strain = item.split("/")[-1]
    new_name = destination + "/" + strain + ".fa"
    if len(fasta_files) == 1:
        # just copy it to destination
        shutil.copyfile(fasta_files[0], new_name)
    else:
        # assume there is one sequence per file
        records = [SeqIO.read(fasta_file, "fasta") for fasta_file in fasta_files]
        # record them
        SeqIO.write(records, new_name, "fasta")

print("Done!")
