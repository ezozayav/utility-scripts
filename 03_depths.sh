

grep 1$ samples.tab  | cut -f1 > ids.in
grep -v 1$ samples.tab  | cut -f1 > ids.out

cat ids.out | sed 's/$/.bam/' > ids.out.fofn
cat ids.in  | sed 's/$/.bam/' > ids.in.fofn

cat ids.in  | wc -l  > in.bam.count
cat ids.out | wc -l > out.bam.count

samtools depth -f ids.in.fofn  -aa --reference MCHIM.fna >  in.depths
samtools depth -f ids.out.fofn -aa --reference MCHIM.fna > out.depths

wc -l in.depths out.depths
