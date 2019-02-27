#!/usr/bin/perl
use strict;
use warnings;

#initializing values
my @total_length; 
my $sum=0;
my @positive_strand;
my @negative_strand;
my @sorted_values;
my $sum_of_squares=0;

my $file = $ARGV[0] or die "Need to get bed file on the command line"; 
open(my $data, '<', $file) or die "Could not open '$file' $!";

while (my $line = <$data>)
{
	my @fields = split (/\s+/ , $line); #splitting the fields
	push @total_length,(($fields[2] - $fields[1])+1);#total length is start minus stop plus 1
	$sum=$sum+(($fields[2] - $fields[1])+1);#getting the sum of entries
	if ($fields[5] eq '+')
	{
		push @positive_strand,$fields[5];#only positive strand
	}
	else
	{
		push @negative_strand,$fields[5];#only negative strand
	}

	
	
}
@sorted_values = sort {$a <=> $b} @total_length;#sorting to get longest length at end and shortest length at start

my $total_number_of_entries = scalar @total_length;#total entries
my $average_length= $sum/$total_number_of_entries;


my $entries_positive_strand = scalar @positive_strand; #positive strand entries
my $entries_negative_strand = scalar @negative_strand; #negative strand entries
#print "$sum\n";
#print $sorted_values[-1];#longest entry
#print $sorted_values[0];#shortest entry

foreach my $i (@total_length)
{
	$sum_of_squares += ($i - $average_length)**2#calculating sum of squares
}

my $standard_deviation = sqrt($sum_of_squares/($total_number_of_entries - 1));#calculating standard deviation

print "\nTotal number of entries: $total_number_of_entries\n";
print  "\nTotal length of entries: $sum\n"; 
print "\nNumber of entries on + strand: $entries_positive_strand\n"; 
print "\nNumber of entries on - strand: $entries_negative_strand\n";
print "\nLongest entry: $sorted_values[-1]\n";
print "\nShortest entry: $sorted_values[0]\n"; 
print "\nAverage gene length : $average_length\n";
print "Standard deviation of gene length: $standard_deviation\n";

