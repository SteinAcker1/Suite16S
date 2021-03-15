#!/bin/sh
cat taxa/taxon.txt | cut -d$'\t' -f 11-16 | tr -d '[:punct:]' | tr -d " " | sed 's/awaitingallocation//g' |  grep 'Bacteria' | awk 'NF==6{print}{}' | sed '1s/^/kingdom\tphylum\tclass\torder\tfamily\tgenus\n/' > taxa/bacteriaTaxa.tsv
sqlite3 taxa/bacteriaTaxa.sqlite3 <<END_SQL
.separator "\t"
DROP TABLE taxa;
CREATE TABLE taxa (kingdom text, phylum text, class text, "order" text, family text, genus text);
.import taxa/bacteriaTaxa.tsv taxa
END_SQL
