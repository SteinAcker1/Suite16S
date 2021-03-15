#!/bin/sh
cat taxa/taxon.txt | cut -d$'\t' -f 11-16 | tr -d '[:punct:]' | sed 's/awaiting allocation//' | tr -d " " | grep 'Bacteria' | awk 'NF==6{print}{}'> taxa/bacteriaTaxa.tsv
sqlite3 taxa/bacteriaTaxa.sqlite3 <<END_SQL
.separator "\t"
DROP TABLE taxa;
CREATE TABLE taxa (kingdom, phylum, hello, order, family, genus);
.import taxa/bacteriaTaxa.tsv taxa
END_SQL
