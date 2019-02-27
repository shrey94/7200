#!/usr/bin/perl
use strict;
use warnings;
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $file3 = $ARGV[2];
my %ID_and_name;
my @matching_id;
my $i=0;


open(FILE1, '<', $file1) or die("Can't open file");#taking files and storing it in an array
my @knowngene = <FILE1>;
open(FILE2, '<', $file2) or die("Can't open file");
my @kgXref  = <FILE2>;
open(FILE3, '<', $file3) or die("Can't open file");
my @ID_genesets = <FILE3>;



foreach my $line (@kgXref)
{
	chomp $line;
	my @fields1 = split (/\t/, $line);#splitting
	my $gene_name = $fields1[4];#storing gene name from kgref in an array
	my $kg_ID= $fields1[0];#storing kgID in an array
	
	foreach $i (@ID_genesets)
	{
		# print "$i\n";
		# print "$gene_name\n";
		$i =~ s/\R//g;#encountered this error because it was not matching so used substitution
		if($i eq $gene_name)
		{
			$ID_and_name{ $kg_ID } = $gene_name; #kg_ID is key and gene name is value
		}
	} 
}
print "gene\tstart\tstop\n";
foreach my $keys (keys %ID_and_name)

{
	foreach my $j (@knowngene)
	{
		chomp $j;
		my @fields2 = split (/\t/, $j);
		my $a = $fields2[0];#taking the geneid from knowngene text file

		
		if ($a eq $keys)#equating keys with the geneid and only then printing
		{
		print "$ID_and_name{$keys}\t$fields2[3]\t$fields2[4]\n";
		}	
	}
}