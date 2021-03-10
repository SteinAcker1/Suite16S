import sys
import module
import re

fastq = sys.argv[1]
primers = sys.argv[2]
outfile = sys.argv[3]

primers = primers.sep(",")
primers_regex = ""
for p in primers:
    p = module.create_DNA_regex(p)
    primers_regex += "^" + p + "|"
primers_regex = primers_regex[:-1]
primers_regex = re.compile(primers_regex)

with open(fastq, "r") as fq and open(outfile, "w") as o:
    for line in fq:
        if primers_regex.match(line):
            firstlen = len(line)
            line = primers_regex.sub('', line)
            lastlen = len(line)
            l = firstlen - lastlen
            flag = 1
        elif flag and line.strip() != "+":
            line = line[l:]
            flag = 0
        o.write(line)
