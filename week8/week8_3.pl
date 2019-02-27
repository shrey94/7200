#!/usr/bin/perl
use strict;
use warnings;


my $file = $ARGV[0] or die "Need to get text file on the command line"; 
open(my $data, '<', $file) or die "Could not open '$file' $!";

#initializing values
my @repName;
my @repClass;
my @repFamily;
my %name;
my %rclass;
my %family;


while (my $line = <$data>)#reading line by line
 {
 	chomp $line;
 	my @fields = split (/\s+/ , $line);
 	#finding which column numbers have repName, repClass and repFamily value and pushing them in an array
 	push(@repName, $fields[10]);
    push(@repClass, $fields[11]);
    push(@repFamily, $fields[12]);

}

shift @repName;
shift @repClass;
shift@repFamily;


print "###########THIS IS REPNAME TABLE ##############################\n";
$name{$_}++ foreach @repName; #taking each element in repName array and making it a key %name and appying a counter to its values
print "$_ Has $name{$_} occurences\n" foreach keys %name; 
print "###########################################\n";


print "########THIS IS REPCLASS TABLE ###################################\n";
$rclass{$_}++ foreach @repClass;
print "$_= $rclass{$_}\n" foreach keys %rclass;
print "###########################################\n";

print "##############THIS IS REPFAMILY TABLE #############################\n";
$family{$_}++ foreach @repFamily;
print "$_=$family{$_}\n" foreach keys %family;
print "###########################################\n";