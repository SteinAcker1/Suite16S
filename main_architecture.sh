#!/bin/sh
trim_primer=false
trim_badness=false
single=false
paired=false

while getopts ":i:p:t:" opt; do
  case ${opt} in
    i) single=true; fastq=$OPTARG ;;
#    'input_pe') paired=true; r1=$(echo $OPTARG | cut -d " " -f 1); r2=$(echo $OPTARG | cut -d " " -f 2) ;;
    p) trim_primer=true; primers=$OPTARG ;;
    t) trim_badness=true; trimmomatic_input=$OPTARG ;;
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
fi
