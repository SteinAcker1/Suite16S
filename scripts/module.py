def get_complement(seq):
    #Produces the complementary sequence of DNA in the 5'-3' direction
    table = seq.maketrans('ACTGactg','TGACtgac')
    comp = seq.translate(table)
    return comp

def create_DNA_regex(seq):
    #Translates IUPAC nucleotide codes into computer-readable regular expressions
    seq = seq.upper()
    symbols = {ord('Y'):'[CT]',
               ord('R'):'[AG]',
               ord('S'):'[CG]',
               ord('W'):'[AT]',
               ord('K'):'[GT]',
               ord('M'):'[CA]',
               ord('B'):'[CGT]',
               ord('D'):'[AGT]',
               ord('H'):'[CAT]',
               ord('V'):'[CGA]',
               ord('N'):'[ACGT]'}
    return seq.translate(symbols)

def fastq_to_fasta(fastq):
    #Converts FASTQ files to FASTA format
    fasta = []
    for line in range(len(fastq)):
        if fastq[line][0] == '@' and line != len(fastq)-1:
            if not re.search('[^ACTGactg]',fastq[line+1].strip('\n')):
                fasta.append('>' + fastq[line][1:])
        elif not re.search('[^ACTGactg]',fastq[line].strip('\n')):
            fasta.append(fastq[line])
    return fasta
