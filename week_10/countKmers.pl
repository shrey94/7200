#!/usr/bin/perl 
use strict;
use warnings;
my $file = $ARGV[0];
my $number = $ARGV[1];#taking number from user
my %hash;#initializing hash


unless (open (FILE, $file)) {
	print " file not in correct format \n";
	exit;
}

while (my $line = <FILE>) {
    next if $. < 2; # Skip first line
    chomp $line;
      
    	my $sequence = $line;#as while reads line by line, every time my sequence will be new, so sequence=line
    	#print $sequence;

 	for (my $i=0;$i <length($sequence) - $number;$i++) {
        my $kmer = substr($sequence, $i, $number);#taking kmers using substr inside loop
        if (exists $hash{$kmer}){
        	$hash{$kmer}+=1;#putting values inside the hash
        }
        else{
        	$hash{$kmer} = 1;
        }


 		

 	}
}

foreach my $name (sort keys %hash) {#printing in alphabetical order
    print"$name\t$hash{$name}\n";
}

