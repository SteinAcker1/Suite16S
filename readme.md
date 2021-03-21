TITLE: Suite16S

AUTHOR: Stein Acker (GitHub: SteinAcker1; email: st1851ac-s@student.lu.se)

BASH VERSION: 5.0.17(1)-release

SQLITE VERSION: 3.34.0

R VERSION: 4.0.4 "Lost Library Book"

PYTHON VERSION: 3.9.2

REQUIRED THIRD-PARTY SOFTWARE: Trimmomatic (v0.39), PANDAseq (v2.11), BLASTn (v2.11.0)

REQUIRED R PACKAGES: dplyr (v1.0.4), ggplot2 (v3.3.3)

USAGE:
-i 	(required) (input) Provides one or two FASTQ read file(s) (one if single end, two comma-separated if paired end)
-p	(input) Allows user to trim specific inputted primer sequences. Enter as comma-separated.
-t	(input) Allows user to use Trimmomatic with user-specified settings. Input should be in double quotations.
-d	(input) Allows user to specify a BLAST database to use other than the default RefSeq 16s database
-c  (input) Allows user to specify how many cores to use in analysis (default = 2)
-n  (input) Allows user to specify a file stem in the project (default: myproject)
-h  (boolean) Prints this help screen and exits

EXAMPLE: suite16s.sh -i sample_forward.fastq,sample_reverse.fastq -c 16 -t "LEADING:20 TRAILING:20 SLIDINGWINDOW:8:15 MINLEN:140 AVGQUAL:20" -n An_Excellent_Name -p ACGGACACA,ACATTTTACG

INSTALLATION INSTRUCTIONS:
1) Ensure all required packages listed above are installed on your machine.
2) Download full repository from GitHub.
3) Move the repository to your ~/bin directory.
4) Append the following line to your .bashrc (or equivalent) file:

export PATH="$PATH:/$HOME/bin/Suite16S/"

5) Enter "source ~.bashrc" (or equivalent) in the command line.
6) Test the program by navigating to a different directory and entering "suite16s.sh -h" in the command line.
   If the help page shows up, congratulations! The program is ready to use. Enjoy!

PROCEDURE:
0) (Optional and situation-based) Use trim_primers.py, PANDAseq, and/or Trimmomatic if indicated
1) Convert the FASTQ file into a FASTA file using the fastq_to_fasta.py script
2) Run BLASTn on the resulting FASTA file
3) Scrape the top hit from each BLAST query and add it to blast_output.txt
4) Append full taxonomical data to the BLAST output and save to foundTaxa.csv
5) Use diversity.R to generate diversity statistics for each taxonomic level, excluding taxa with fewer than 5 representatives to mitigate the risk of false hits
6) Use diversity.R to generate bar plots for the top ten genera and top five phyla, also excluding taxa with fewer than 5 representatives

FILE TREE REQUIRED FOR USE:
~/bin/Suite16S
      ├── db
      │   ├── bacteria.16SrRNA.fna
      │   ├── bacteria.16SrRNA.fna.ndb
      │   ├── bacteria.16SrRNA.fna.nhr
      │   ├── bacteria.16SrRNA.fna.nin
      │   ├── bacteria.16SrRNA.fna.nog
      │   ├── bacteria.16SrRNA.fna.nos
      │   ├── bacteria.16SrRNA.fna.not
      │   ├── bacteria.16SrRNA.fna.nsq
      │   ├── bacteria.16SrRNA.fna.ntf
      │   └── bacteria.16SrRNA.fna.nto
      ├── readme.md
      ├── scripts
      │   ├── diversity.R
      │   ├── fastq_to_fasta.py
      │   ├── getBacteriaSQL.sh (not required for use, but shows how taxa/bacteriaTaxa.sqlite3 was developed from the taxon.txt file downloaded from the link below)
      │   ├── module.py
      │   ├── plotting.R
      │   └── trim_primers.py
      ├── suite16s.sh
      └── taxa
          └── bacteriaTaxa.sqlite3

OUTPUT FILE TREE (paired end, trimming functionality enabled, no primers):
.
├── 0_trimming
│   ├── myproject_1P.fastq
│   ├── myproject_1U.fastq
│   ├── myproject_2P.fastq
│   └── myproject_2U.fastq
├── sample_forward.fastq
├── sample_reverse.fastq
├── blast
│   ├── blast_output.txt
│   └── myproject.fasta
├── 1_merged
│   ├── myproject.fastq
│   ├── myproject.log
│   └── myproject_unaligned.fasta
└── output
    ├── myproject_diversity.tsv
    ├── myproject_genus_plot.svg
    ├── myproject_genus.tsv
    ├── myproject_phylum_plot.svg
    ├── myproject_phylum.tsv
    └── myproject_species.tsv

 (Note: if only one FASTQ file is inputted, there will be no 1_merged/ directory. If
   the -t flag is not used, there will be no 0_trimming/ directory. If primers need to
   be removed, new files with the format (sample name)_noprimers.fastq will appear in
   the main directory.)

Test files "G35348_R1_001.fastq" and "G35348_R2_001.fastq" found at https://diabimmune.broadinstitute.org/diabimmune/t1d-cohort/resources/16s-sequence-data
Primers used by Diabimmune research group: 515F [GTGCCAGCMGCCGCGGTAA] and 806R [GGACTACHVGGGTWTCTAA] (source: https://www.cell.com/cell-host-microbe/pdfExtended/S1931-3128(15)00021-9)

NCBI RefSeq downloaded from ftp://ftp.ncbi.nlm.nih.gov/refseq/TargetedLoci/Bacteria//bacteria.16SrRNA.fna.gz

Taxa list downloaded from https://www.irmng.org/export/2020/IRMNG_genera_DwCA_2020-03-24.zip

Link to some (large) extra input/output examples involving termites: https://drive.google.com/drive/folders/1j3WiHsl6f0LuPRxgRvcMifwilmtbPMCG?usp=sharing
