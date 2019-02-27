#!/usr/bin/perl
use strict;
use warnings;


my @array_numbers; 
my $number;
#running a loop until user enters zero
while(1)
{
#asking for a number from user
	print "Please enter a number (if you want to exit put 0): "; 
	$number=<STDIN>;
	chomp($number);
	#adding numbers to array if number is +ve at the end
 	if($number>0)
	{
		push (@array_numbers,$number); 
	}
	#adding number to front if number is -ve 
	elsif($number<0)
	{
		unshift (@array_numbers,$number); 
	}
	elsif ($number==0)#exiting when number entered is 0
	{
		last;
	}
}
	#converting array to string and printing 
	$number=join(".",@array_numbers);
	print "\nThese are numbers: $number";
	#initializing sum variable
	my $sum=0;
#	calculating sum of all elements in the array
 foreach my $i(@array_numbers)
{ $sum+=$i; }
print "\nSum of all elements: $sum\n";