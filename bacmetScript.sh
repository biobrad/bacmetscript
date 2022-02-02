#!/bin/bash
#
#Bacmet2 script - Written by Brad Hart July 2021
#.faa folders to be a folder from the script directory called faas
#Diamond to be an executable in a folder from home called softwarebins/
#further refinement and changes required before integrating into tormes.
#
samp=$(basename -a faas/*.faa | sed 's/\.faa//g')
#
for i in ${samp}; do
diamond blastp -q faas/${i}.faa -p 12 -d bacmet2pre.dmnd --query-cover 90 --id 99.7 -b 8 -o ${i}bacmet2prepairwise -f 0
diamond blastp -q faas/${i}.faa -p 12 -d bacmet2pre.dmnd --query-cover 90 --id 90 -b 8 -o ${i}bacmet2pretable -f 6 qseqid sseqid qlen slen pident length mismatch gapopen qstart qend sstart send evalue bitscore
grep ">" ${i}bacmet2prepairwise | awk -F "|" '{print $4}' > ${i}prehits
while read line; do
grep ${line} bacmet2_premapping.txt | awk '{print $0 "\n"}' | tee -a ${i}bcmt2PRE_results.txt >> ${i}bcmt2pre_nopairwise.txt
cat ${i}bacmet2prepairwise | sed -n "/$line/,/Query=/p" | head -n -1 | >> ${i}bcmt2PRE_results.txt
echo "" >> ${i}bcmt2PRE_results.txt
done<${i}prehits
#
diamond blastp -q faas/${i}.faa -p 12 -d bacmet2exp.dmnd --query-cover 90 --id 90 -b 8 -o ${i}bacmet2exppairwise -f 0
diamond blastp -q faas/${i}.faa -p 12 -d bacmet2exp.dmnd --query-cover 90 --id 90 -b 8 -o ${i}bacmet2exptable -f 6 qseqid sseqid qlen slen pident length mismatch gapopen qstart qend sstart send evalue bitscore
grep "|" ${i}bacmet2exppairwise | awk -F "|" '{print $1}' | sed 's/>//g' > ${i}exphits
while read line; do
grep ${line} bacmet2_expmapping.txt | awk '{print $0 "\n"}' | tee -a ${i}bcmt2EXP_results.txt >> ${i}bcmt2exp_nopairwise.txt
cat ${i}bacmet2exppairwise | sed -n "/$line/,/Query=/p" | head -n -1 >> ${i}bcmt2EXP_results.txt
echo "" >> ${i}bcmt2EXP_results.txt
done<${i}exphits
#
#Scruba-dub-dub
#
rm -rf ${i}{pre,exp}hits
rm -rf ${i}bacmet2{pre,exp}pairwise
mkdir -p results/${i}bcmt2results
mv ${i}bcmt2{EXP,PRE}_results.txt results/${i}bcmt2results
mv ${i}bcmt2{pre,exp}_nopairwise.txt results/${i}bcmt2results
done
