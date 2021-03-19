#!/bin/sh
trim_primer=false
trim_badness=false
paired=false
database=~/Proj_BINP29/db2/bacteria.16SrRNA.fna
calculateDiversity=false
getPlots=false
file_stem="myproject"
cores=2

#Set options
while getopts ":i:p:t:d:n:c:sp" opt; do
  case ${opt} in
    i) fastq=$OPTARG ;;
    p) trim_primer=true; primers=$OPTARG ;;
    t) trim_badness=true; trimmomatic_input=$OPTARG ;;
    d) database=$OPTARG ;;
    n) file_stem=$OPTARG ;;
    c) cores=$OPTARG ;;
    s) calculateDiversity=true ;;
    p) getPlots=true ;;
    \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

#Identify file stem
#file_stem=${fastq%.fastq}
#file_stem=${file_stem##*/}

#Detect if this is a paired-read input
if [[ $fastq == *","* ]]; then
  paired=true
  read1=$(echo $fastq | cut -d "," -f 1)
  read2=$(echo $fastq | cut -d "," -f 2)
fi

#Trim primers if indicated
if $trim_primer
then
if $paired
  then
    python3 ~/Proj_BINP29/scripts/trim_primers.py $read1 $primers data/${file_stem}_noprimers.fastq
    read1=${read1%.fastq}_noprimers.fastq
    python3 ~/Proj_BINP29/scripts/trim_primers.py $read2 $primers data/${file_stem}_noprimers.fastq
    read1=${read2%.fastq}_noprimers.fastq
  else
    python3 ~/Proj_BINP29/scripts/trim_primers.py $fastq $primers data/${file_stem}_noprimers.fastq
    fastq=${fastq%.fastq}_noprimers.fastq
  fi
fi

#Use Trimmomatic if indicated
if $trim_badness
then
  mkdir 0_trimming
  if $paired
  then
    trimmomatic PE -baseout 0_trimming/${file_stem}.fastq $read1 $read2 -threads $cores $trimmomatic_input
    read1=0_trimming/${file_stem}_1P.fastq
    read2=0_trimming/${file_stem}_2P.fastq
  else
    trimmomatic SE $fastq 0_trimming/${file_stem}_trimmed.fastq -threads $cores $trimmomatic_input
    fastq=0_trimming/${file_stem}_trimmed.fastq
  fi
fi

#Use PandaSeq to merge reads if paired
if $paired
then
  mkdir 1_merged
  pandaseq -f $read1 -r $read2 -g 1_merged/${file_stem}.log -u 1_merged/${file_stem}_unaligned.fasta -w 1_merged/${file_stem}.fastq -F -B
  fastq=1_merged/${file_stem}.fastq
fi

#Use BLAST and identify top hit for each read
mkdir blast
python3 ~/Proj_BINP29/scripts/fastq_to_fasta.py $fastq blast/${file_stem}.fasta
fasta=blast/${file_stem}.fasta
blast_output=blast/blast_output.txt
blastn -query $fasta -db $database -num_threads $cores | grep -A 2 'Sequences' | grep NR | cut -d " " -f 2-3 > $blast_output

#Get full taxonomical data for each read using SQL
mkdir sampleTaxonData
> sampleTaxonData/foundTaxa.csv
echo -e 'kingdom|phylum|class|order|family|genus|species' >> sampleTaxonData/foundTaxa.csv
cat blast/blast_output.txt | while read line
do
  genus=$(echo $line | cut -d " " -f 1 | tr -d '[:punct:]')
  species=$(echo $line | cut -d " " -f 2 | tr -d '[:punct:]')
  sqlQuery=$(echo 'SELECT kingdom, phylum, class, "order", family FROM taxa WHERE genus="iter";' | sed "s/iter/$genus/")
  taxon=$(echo "$sqlQuery" | sqlite3 ~/Proj_BINP29/taxa/bacteriaTaxa.sqlite3)
  if [[ $taxon == "" ]]; then
    taxon=$(echo '||||')
  fi
  echo $taxon'|'$genus'|'$species >> sampleTaxonData/foundTaxa.csv
done

#Use R to generate diversity statistics and/or plot if indicated
mkdir output

if [[ $calculateDiversity ]]; then
  Rscript ~/Proj_BINP29/scripts/diversity.R
fi

if [[ $getPlots ]]; then
  Rscript ~/Proj_BINP29/scripts/plotting.R
fi
