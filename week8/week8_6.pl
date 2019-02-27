#!/usr/bin/perl
use strict;
use warnings;

#ATGC
#TACG

print "Please enter a pattern : "; 
	my $pattern=<STDIN>;
	chomp $pattern;

my $len= length($pattern);#calculating length
my @firsthalfp;#defining array for first half
my @secondhalfp;#defining array for second half
my $reversepattern= reverse($pattern); #taking reverse of user entered pattern



for (my $i=0; $i <int($len/2); $i++)#running a loop for the 1st half of the string and pushing it in array
{
	
	
	push @firsthalfp,substr($pattern,$i,1);
}
print @firsthalfp;


for (my $j= 0 ; $j <int($len/2); $j++)#running a loop for the 2nd half of the string on the reversed pattern and pushing it in array
{
	push @secondhalfp,substr($reversepattern,$j,1);	
}


my $string1 =join("",@firsthalfp);#converting to a scalar for comparison
my $string2 = join ("",@secondhalfp);

$string1=~ tr/ATGC/TACG/;#carrying out the translation for complement 
	


if ($string1 eq $string2)#running the comparison
{
	print "Yes it is\n";
}
else{
	print "No, its not\n";
}