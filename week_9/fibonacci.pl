#!/usr/bin/perl 
use strict;
use warnings;
my $number = $ARGV[0];#taking number from argument

my @result;#defining my array which will have the result 
for (my $i=0;$i<$number;$i++)#running a loop that will iterate through each element and push values in result array
	{
	push @result,(fibonacci($i)); #pushing the result while calling the function again and again
	}


sub fibonacci
{
   my ($number_ref) = @_;
   
   if ($number_ref <2){#if entered number less than 2 then return the number back
   	
   	return ($number_ref);
	}  
   else{

     return fibonacci($number_ref - 1) + fibonacci($number_ref - 2);#recursive fibonacci

   }
}

print "Function\tOutput\n";
print "Fibonacci($number)\t@result\n";