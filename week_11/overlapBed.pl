#!/usr/bin/perl 
use List::Util qw[min max];
use strict;
use warnings;
use Getopt::Long qw[GetOptions];

my $file1 = "";
my $file2 = "";
my $userpercentage = "";
my $output = "";
my $join=0;


GetOptions("i1=s"   =>      \$file1,
            "i2=s"  =>      \$file2,
             "m=i"    =>      \$userpercentage,
             "j=i"    =>      \$join,
              "o=s"  =>       \$output,
                        );
#overlap.pl -i1 TE.bed -i2 Intron.bed -m 50 -j -o testOutput 



unless (open (FILE1, $file1)) {
    print " file not in correct format \n";
    exit;
}

unless (open (FILE2, $file2)) {
    print " file not in correct format \n";
    exit;
}

my @firstfile = <FILE1>;
my @secondfile = <FILE2>;
my @fields1;
my @fields2;
my $start1;
my $stop1;
my $start2;
my $stop2;


my $c=0;

open (FILE_OUT, ">", "$output");

OUTER: for (my $i=0; $i< scalar(@firstfile); $i++)
{	
	chomp $firstfile[$i];
	@fields1 = split(/\t/,$firstfile[$i]);

	 $start1 = $fields1[1];
	 $stop1 = $fields1[2];

	INNER: for(my $j=$c ; $j< scalar(@secondfile); $j++)
	{
		chomp $secondfile[$j];
		@fields2 = split (/\t/,$secondfile[$j]);
		$start2 = $fields2[1];
		$stop2 = $fields2[2];
		if ($fields1[0] eq $fields2[0])
		{	
			if ($stop1 <= $start2){
				next OUTER;
			}
			my $overlappercentage = perc_overlap($start1,$stop1,$start2,$stop2);
				

			if ($overlappercentage >= $userpercentage){
				if ($join==1){

					print FILE_OUT "$fields1[0]\t$start1\t$stop1\t$fields2[0]\t$start2\t$stop2\n";
					$c=$j;

					next OUTER;
				}
				else {
					print FILE_OUT "$fields1[0]\t$start1\t$stop1\n";
					$c=$j;

					next OUTER;

				}
			}
		}


	}


}


sub perc_overlap{
	my ($sta1,$sto1,$sta2,$sto2) = @_;
	my @stop_list = ($sto1,$sto2);
	my @start_list = ($sta1,$sta2);
	my $max_sta = max @start_list;
	my $min_sto = min @stop_list;
	my $overlap = $min_sto - $max_sta;
	my $op= ($overlap/($sto1 - $sta1))*100;
	return $op;


}
close(FILE_OUT);
