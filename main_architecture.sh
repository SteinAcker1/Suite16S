#!/bin/sh
trim_primer=false
trim_badness=false
single=false
paired=false
database=db2/bacteria.16SrRNA.fna

while getopts ":i:p:t:d:" opt; do
  case ${opt} in
    i) single=true; fastq=$OPTARG ;;
#    'input_pe') paired=true; r1=$(echo $OPTARG | cut -d " " -f 1); r2=$(echo $OPTARG | cut -d " " -f 2) ;;
    p) trim_primer=true; primers=$OPTARG ;;
    t) trim_badness=true; trimmomatic_input=$OPTARG ;;
    d) database=$OPTARG ;;
    \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

file_stem=${fastq%.fastq}
file_stem=${file_stem##*/}

if ${trim_primer}
then
  python3 scripts/trim_primers.py $fastq $primers data/${file_stem}_noprimers.fastq
  fastq=${fastq%.fastq}_noprimers.fastq
fi

if $trim_badness
then
  mkdir 0_trimming
  trimmomatic SE $fastq 0_trimming/${file_stem}_trimmed.fastq $trimmomatic_input
  fastq=0_trimming/${file_stem}_trimmed.fastq
fi

mkdir blast
python3 scripts/fastq_to_fasta.py $fastq blast/${file_stem}.fasta
fasta=blast/${file_stem}.fasta
blast_output=blast/blast_output.txt
blastn -query $fasta -db $database | grep -A 2 'Sequences' | grep NR | cut -d " " -f 2-3 > $blast_output

mkdir sampleTaxonData
cat blast/blast_output | while read line
do
  genus=$(cut -d " " -f 1 line | tr -d '[:punct:]')
  species=$(cut -d " " -f 2 line | tr -d '[:punct:]')
  taxon=$(cat taxa/taxon.txt | grep 'Bacteria' | grep $genus | cut -d$'\t' -f 12-19 | tr -d '[:punct:]')
  echo -e $taxon'\t'$species >> sampleTaxonData/foundTaxa.tsv
done
