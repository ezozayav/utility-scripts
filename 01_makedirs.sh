#!/bin/bash
set -e
REF=MCHIM.fna
BWA="bwa mem -t 72 -v 3"
SORT="samtools sort --reference $REF -@ 16 -m 32G"

echo "bwa index $REF"
echo "samtools faidx $REF"

for N in $(cut -f 1 samples.tab | grep ^2016); do
	#echo $N
	READS=$(mdu-reads --format R12 $N)
	echo "$BWA $REF $READS | $SORT > $N.bam"
done


for N in $(cut -f 1 samples.tab | grep ^MC); do
	# echo $N
	READS=$(mdu-reads --format R12 --rootdir /mnt/seq/DCAMG/SAHMRI/M.chimaera $N)
	echo "$BWA $REF $READS | $SORT > $N.bam"
done

#for N in $(cut -f 1 samples.tab | grep ^Mycobac); do
for F in $(ls assemblies/*.gbk); do
	N=$(basename $F .gbk)
	READS="<(any2fasta.pl $F)"
	echo "$BWA -x intractg $REF $READS | $SORT > $N.bam"
done

echo "for N in *.bam ; do (samtools index $N &); done"
