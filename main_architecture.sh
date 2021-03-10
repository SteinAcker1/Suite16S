#!/bin/sh

while getopts ":i:p:" opt; do
  case ${opt} in
    i ) fastq=$OPTARG ;;
    p ) trim_primer=true; primers=$OPTARG ;;
    \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

if $trim_primer
then
  python3 scripts/trim_primers.py $fastq $primers ${fastq%.fastq}_noprimers.fastq
  fastq=${fastq%.fastq}_noprimers.fastq
fi
