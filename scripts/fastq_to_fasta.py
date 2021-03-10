import sys

fasta = sys.argv[1]
fastq = sys.argv[2]

count = 4
with open(fasta, "r") as fa, open(fastq, "w") as fq:
    for line in fa:
        if line[0] == '@' and count == 4:
            line = ">" + line[1:]
            fq.write(line)
            count = 0
        if count == 1:
            fq.write(line)
        count += 1
