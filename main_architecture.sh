#!/bin/sh
trim_primer=false
trim_badness=false
single=false
paired=false
database=db2/bacteria.16SrRNA.fna

#Set options
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

#Identify file stem
file_stem=${fastq%.fastq}
file_stem=${file_stem##*/}

#Trim primers if indicated
if ${trim_primer}
then
  python3 scripts/trim_primers.py $fastq $primers data/${file_stem}_noprimers.fastq
  fastq=${fastq%.fastq}_noprimers.fastq
fi

#Use Trimmomatic if indicated
if $trim_badness
then
  mkdir 0_trimming
  trimmomatic SE $fastq 0_trimming/${file_stem}_trimmed.fastq $trimmomatic_input
  fastq=0_trimming/${file_stem}_trimmed.fastq
fi

#Use BLAST and identify top hit for each read
mkdir blast
python3 scripts/fastq_to_fasta.py $fastq blast/${file_stem}.fasta
fasta=blast/${file_stem}.fasta
blast_output=blast/blast_output.txt
blastn -query $fasta -db $database | grep -A 2 'Sequences' | grep NR | cut -d " " -f 2-3 > $blast_output

#Get full taxonomical data for each read using SQL
mkdir sampleTaxonData
> sampleTaxonData/foundTaxa.csv
echo -e 'kingdom|phylum|class|order|family|genus|species' >> sampleTaxonData/foundTaxa.csv
cat blast/blast_output.txt | while read line
do
  genus=$(echo $line | cut -d " " -f 1 | tr -d '[:punct:]')
  species=$(echo $line | cut -d " " -f 2 | tr -d '[:punct:]')
  sqlQuery=$(echo 'SELECT kingdom, phylum, class, "order", family FROM taxa WHERE genus="iter";' | sed "s/iter/$genus/")
  taxon=$(echo "$sqlQuery" | sqlite3 taxa/bacteriaTaxa.sqlite3)
  if [[ ! "$taxon" = ^Bacteria ]]; then
    taxon=$(echo '||||')
  fi
  echo $taxon'|'$genus'|'$species >> sampleTaxonData/foundTaxa.csv
done

#Use R to generate diversity statistics if indicated
mkdir output
Rscript scripts/diversity.R
