#!/usr/bin/perl 
use strict;
use warnings;
my $file = $ARGV[0];
my $file2 = $ARGV[1];

my @start;#
my @end;
my @comb;
my %hash1;
my %hash2;
my @ucombo;
my @chr;
my @usortedcombo;
my @uniques;
my @sorteduniques;

unless (open (FILE, $file)) {
	print " file not in correct format \n";
	exit;
}

while (my $line = <FILE>)	
{
	chomp $line;
	my  @fields = split(/\t/, $line);
	push @chr, $fields[0];

}

foreach my $chromosome (@chr) {
  if (! $hash1{$chromosome}) {
    push @uniques, $chromosome;
    $hash1{$chromosome} = 1;
  }
}

open (FILE_OUT, ">", "$file2");
# print @uniques;

@sorteduniques = sort {$a cmp $b} @uniques;

# print @sorteduniques;
open (FILE,$file);
foreach my $k (@sorteduniques)
{

	while (my $line = <FILE>)

	# print $line;
	{
		chomp $line;
		my @fields2 = split("\t", $line);

		if ($k eq $fields2[0])
		{
			push @start,($fields2[1]);
			push @end,($fields2[2]);
			#print @start;

		}
	}	
		push @comb,(@start,@end); 
		#print @comb;
		foreach my $value (@comb) {
  			if (! $hash2{$value}) 
  			{
    			push @ucombo, $value;
    			$hash2{$value} = 1;
  			}
		}

		@usortedcombo = sort {$a <=> $b} @ucombo;
		#print @ucombo;

	#print "@usortedcombo";

		my $length1= scalar @usortedcombo;
		my $length2 = scalar @end;



		
		for (my $i=0 ; $i < $length1 - 1; $i++)
		{
			my $counter = 0;
			my $startPoint = $usortedcombo[$i];
			my $endPoint = $usortedcombo[$i+1];

			for(my $j=0 ; $j<$length2; $j++)
			{
	
				if (!(($startPoint > $end[$j]) || ($endPoint <= $start[$j])))
				{	

				$counter+=1;
		
				}
			}
	

		    print FILE_OUT "$k\t$startPoint\t$endPoint\t$counter\n";
		}
}

close(FILE_OUT);
