import sys

fastq = sys.argv[1]
primers = sys.argv[2]
outfile = sys.argv[3]

primers = primers.sep(",")

with open(fastq, "r") as fq and open(outfile, "w") as o:
    for line in fq:
        for p in primers:
            if line.startswith(p):
                l = len(p)
                o.write(line[l:])
                flag = 1
            elif flag and line.strip() != "+":
                o.write(line[l:])
                flag = 0
            else:
                o.write(line)
