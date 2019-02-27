#!/usr/bin/perl 
use strict;
use warnings;

my $input_1 = $ARGV[0];#taking input files from the user as well as the type of data(protein or nucleotide)
my $input_2 = $ARGV[1];
my $sequence_type= $ARGV[2];
my $output= $ARGV[3];

unless (open (FILE1, $input_1)) {
	print " file not in correct format \n";
	exit;
}
unless (open (FILE2, $input_2)) {
	print " file not in correct format \n";
	exit;
}

if($sequence_type eq "n"){

	system("makeblastdb -in $input_1 -dbtype 'nucl' -parse_seqids -out DbaseA");#making the database for A and B using makeblastdb
	system("makeblastdb -in $input_2 -dbtype 'nucl' -parse_seqids -out DbaseB");
	system("blastn -db DbaseA -query $input_2 -out outfile1.txt -outfmt '6 qseqid sseqid evalue qstart qend sstart send' -max_target_seqs 1");#running blastn to get the reaults for blast. We use outfmt as 6 as it gives a cleaner representation of the data and it is easier to compare the 2 sequences later
	system("blastn -db DbaseB -query $input_1 -out outfile2.txt -outfmt '6 qseqid sseqid evalue qstart qend sstart send' -max_target_seqs 1");#Setting -max_target_seqs to 1 will give only 1 subject/hit
}

elsif($sequence_type eq "p"){
	system("makeblastdb -in $input_1 -dbtype 'prot' -parse_seqids -out DbaseA");
	system("makeblastdb -in $input_2 -dbtype 'prot' -parse_seqids -out DbaseB");
	system("blastn -db DbaseA -query $input_2 -out outfile1.txt -outfmt '6 qseqid sseqid evalue qstart qend sstart send' -max_target_seqs 1");
	system("blastn -db DbaseB -query $input_1 -out outfile2.txt -outfmt '6 qseqid sseqid evalue qstart qend sstart send' -max_target_seqs 1");

}

else {

    print "\nNot correct input";
}



close(FILE1);
close(FILE2);

#Removing the databases
system("rm DbaseA*");
system("rm DbaseB*");

my %hash1; 

unless (open (FILE3,"outfile1.txt")) {
	print " file not in correct format \n";
	exit;
}
unless (open (FILE4, "outfile2.txt")) {
	print " file not in correct format \n";
	exit;
}
open (FILEOUT, ">","$output");
while (my $line1 = <FILE3>)	
{
	chomp $line1;
	$line1 = substr($line1,4);#removing the lcl| pattern
	my @fields1 = split (/\t/ , $line1);

	$hash1{$fields1[0]} = $fields1[1]; #defining a hash where key is subject_id and vale sequence_id

}

my %hash2;
while (my $line2 = <FILE4>)
{
	chomp $line2;
	$line2 = substr($line2,4);
	my @fields2 = split (/\t/ , $line2);
	
  	$hash2{$fields2[0]}=$fields2[1]; 

}


foreach my $keys ( keys %hash1 )#looping over keys of hash1
{
  my $a=$hash1{$keys};#giving a value of $a to values of hash1 
  if($keys eq $hash2{$a})#
  {
    print FILEOUT "$keys\t$hash1{$keys}\n";
  }
}
close(FILEOUT);
