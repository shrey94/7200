#!/usr/bin/perl
use strict;
use warnings;

my $a = 10;
print "initial value of a : $a\n";
my $b = 20;
print "initial value of b : $b\n";

($a, $b) = ($b, $a);

print "swapped value of a: $a\n";
print "swapped value of b: $b\n";