#!/usr/bin/perl
use strict;
use warnings;

print "Please enter a pattern : "; 
	my $pattern=<STDIN>;
	
my @p= split(//,$pattern); #converting into array
	
my $counter = 0;#initializing counter
foreach my $character (@p)
{
    if ($counter < 0)
    {
    	print "not paired\n";#exiting if any extra curly bracket "}"
    	exit;
    }
    elsif ($character eq "{")
    {
	    $counter += 1;
    }
    elsif ($character eq "}")
    {
        $counter -= 1;
    }
}
    
if ($counter == 0)#only returning values when both are equal
{        # valid
    print " paired\n";
}
