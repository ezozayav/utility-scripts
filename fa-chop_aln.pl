#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Bio::SeqIO;
use List::MoreUtils qw(uniq);

my %opts = ();
GetOptions (\%opts, 'alignment|aln=s', 'coordinates|coor=s','help|h');

if($opts{'help'} || !%opts){
	print "Usage: $0 -aln alignment.fasta -coor coordinates_file.txt\n";
	print "Hint: The alignment file most be in fasta format and the coordinates file most follow the minimum BED format (i.e. only the first 3 columns).\n";
	exit;
}

##### Reads coordinates (in BED format) and saves it in a matrix.
my (@row, @coor);
my %outfiles =();
my $i = 0;
open (COOR, $opts{'coordinates'}) || die "Could not find file $opts{'coordinates'}.\n";
while(<COOR>){
	chomp;
	@row = split(/\t/);
	$coor[$i][0] = $row[1];
	$coor[$i][1] = $row[2];	
	#### Creation of sequence output objects and fasta files.
	$outfiles{"$row[1]-$row[2]"} = Bio::SeqIO->new(-file => ">$row[1]-$row[2].fasta", -format=>'Fasta');		
	$i++;
}
close(COOR);
my $coor_num = $i;

#### Reads alignment (in fasta format), split each sequence into the regions indicated in the coordinates file and writes them into a file for each region.
my $in = Bio::SeqIO->new(-file => $opts{'alignment'}, -format=>'Fasta');
my (@lengths, $frag_size, $new_seq_obj);
while (my $seq_obj = $in->next_seq){
	###### Check that all the sequences in the input fasta file have the same length.
	push(@lengths, $seq_obj->length);
	if (scalar(uniq(@lengths)) > 1){
		die "The input fasta file doesn't seem to contain an alignment as not all the sequences have the same length.\n";
	}
	for($i=0; $i<$coor_num; $i++){
		$frag_size = $coor[$i][1] - $coor[$i][0];  
		$new_seq_obj = Bio::Seq->new(-seq=>substr($seq_obj->seq, $coor[$i][0], $frag_size),
        							-display_id => $seq_obj->display_id . ":" . $coor[$i][0] . "-" . $coor[$i][1],
        							-alphabet => "dna" );
		$outfiles{"$coor[$i][0]-$coor[$i][1]"}->write_seq($new_seq_obj);	
	}	
}






