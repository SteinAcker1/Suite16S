#!/bin/sh
trim_primer=false
trim_badness=false

while getopts ":i:p:tf" opt; do
  case ${opt} in
    i) fastq=$OPTARG ;;
    p) trim_primer=true; primers=$OPTARG ;;
    t) trim_badness=true ;;
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
  trimmomatic SE -trimlog 0_trimming/${file_stem}.log 0_trimming/${file_stem}_trimmed.fastq $fastq 0_trimming/${file_stem}_trimmed.fastq
fi
