#!/bin/sh

while getopts ":i:p:"; do
  case ${opt} in
    i ) fastq=$OPTARG ;;
    p ) trim_primer=true; primers=$OPTARG
    \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
  esac
done

if $trim_primer
then
  python3 scripts/trim_primer.py $fastq $primers ${fastq%.fastq}_aligned.fastq
fi
