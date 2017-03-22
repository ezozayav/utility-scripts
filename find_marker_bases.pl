#!/usr/bin/env perl
use strict;
use Bio::SeqIO;
use List::Util qw(sum min max);
use List::MoreUtils qw(any all);

my $MISSING = 'n';
my $REF = "MCHIM.fna";
my $OUTREF = "mchim-targets.fa";
my $IN_DEPTH = "in.depths";
my $OUT_DEPTH = "out.depths";

my %seq;
my $ref = Bio::SeqIO->new(-file=>$REF, -format=>'fasta');
while (my $s = $ref->next_seq) {
  $seq{ $s->id } = uc($s->seq)
}
my $nseq = scalar keys %seq;
my $nbp = sum( map { length $_ } values %seq );
print STDERR "Found $nseq sequences totalling $nbp in $REF\n";

open my $in_fh, '<', $IN_DEPTH;
open my $out_fh, '<', $OUT_DEPTH;


while (not eof $in_fh) {

  my $in = <$in_fh>;
  my $out = <$out_fh>;

  chomp $out;
  my($chr,$pos,$YONGO,@out) = split m/\t/, $out;

  print STDERR "Done $pos/$nbp so far\n" if $pos % 1_000_000 == 0;

  # important logic here
  if (any { $_ > 0 } @out) {
#    print "OUT=$out\n";
    substr $seq{$chr}, $pos-1, 1, $MISSING;
    next;
  }
  
  chomp $in;
  my($chr2,$pos2,@in) = split m/\t/, $in;
  if (any { $_ == 0 } @in) {
    substr $seq{$chr2}, $pos2-1, 1, $MISSING;
    next;
  }
  
#  print "LOC=$chr:$pos\n";
#  print "IN=@in\n";
#  print "OUT=@out\n";
}

my $fout = Bio::SeqIO->new(-file=>">$OUTREF", -format=>'fasta', -alphabet=>'dna');
for my $id (sort keys %seq) {
  $fout->write_seq( 
    Bio::Seq->new(-id=>$id, -seq=>$seq{$id})
  );
}

print STDERR "Result in: $OUTREF\n";

