#!/usr/bin/perl 
use strict;
use warnings;
my $file1= $ARGV[0];#taking the 2 files from the users that contain the sequence
my $file2 = $ARGV[1];
my @matrix;
my $Match = 1;#defining match mismatch and gap score According to the question
my $Mismatch = -1;
my $Gap = -1;
my $firstseq;
my $secondseq;

unless (open (FILE1, $file1)) {
    print " file not in correct format \n";
    exit;
}

unless (open (FILE2, $file2)) {
    print " file not in correct format \n";
    exit;
}

while (my $line1 = <FILE1>){
	chomp $line1;
	$firstseq = $line1;#making the $line my sequence 1
}
while (my $line2 = <FILE2>){
	chomp $line2;
	$secondseq=$line2;#making the $line my sequence 2
}
my $length1= length($firstseq);
my $length2 = length($secondseq);


for (my $i=0; $i <=$length2; $i++){
    for (my $j=0; $j<=$length1; $j++){
    	$matrix[$i][$j]=0;#defining an empty matrix
    #print "$matrix[$i][$j] ";

    }
    #print "\n";
}


for (my $i = 1; $i <=$length2; $i++) {
    $matrix[$i][0] = $Gap;
    $Gap= $Gap - 1;#filling the gap scores in first row and column
}

$Gap = -1; 

for (my $j=1; $j<=$length1; $j++){
	$matrix[0][$j] = $Gap;
	$Gap= $Gap - 1;

}

$Match = 1;
$Mismatch = -1;
$Gap = -1;



for(my $x = 1; $x <= $length2; $x++) { #going through sequence1
   for(my $y = 1; $y <= $length1; $y++) { #going through sequence2

        my $up;
        my $left;
        my $diagonal;

        my $seq1_first = substr($firstseq,$y-1,1);#taking the bases using substr inside the loop
        my $seq2_first = substr($secondseq,$x-1,1); 

        if($seq1_first eq $seq2_first) {
             $diagonal = $matrix[$x-1][$y-1] + $Match;#match condition
        }
        else {
             $diagonal = $matrix[$x-1][$y-1] + $Mismatch;#mismatch condition
        } 


        $up = $matrix[$x-1][$y] + $Gap; #gap score defined
        $left = $matrix[$x][$y-1] + $Gap;
        
        	$matrix[$x][$y] = max($diagonal,$up,$left);#taking the maximum out of the 3 using my max subroutine
    }
}

for (my $x = 0; $x <=$length2; $x++) {
	for (my $y=0; $y<=$length1; $y++){
		#printf "%4d","$matrix[$x][$y] ";
	}
	#print "\n";
}


sub max{
	my ($diagonal,$up,$left) = @_;

	if ($diagonal >= $up) {
        if ($diagonal >= $left) {
        		
                return ($diagonal);
            }
        else{
                return ($left);
            }
    } 
    elsif ($up >= $left) 
    	{
                return ($up);
         }
     else 
     {
                return ($left);
     }

}

sub max_pos{
	my ($diagonal,$up,$left) = @_;

	if ($diagonal >= $up) {
        if ($diagonal >= $left) {
        		
                return (1);
            }
        else{
                return (2);
            }
    } 
    elsif ($up >= $left) 
    	{
                return (3);
         }
     else 
     {
                return (2);
     }

}

######TRACEBACK############
my @alignment1;#initialization of alignment array
my @alignment2;

my $j=length($firstseq);#defining lengths
my $i=length($secondseq);
my $dash="-";#dash for gap

do{ 
	if ((substr($firstseq,$j-1,1)) eq (substr($secondseq,$i-1,1))) {#mandatory condition if the bases of 2 sequences match
	unshift @alignment1,(substr($firstseq,$j-1,1));
	unshift @alignment2,(substr($secondseq,$i-1,1));

	$i=$i-1;
	$j=$j-1;
	}
	else
	{	
		my $diag = $matrix[$i-1][$j-1];#again defining diagnol,up,left
		my $u = $matrix[$i-1][$j];
		my $l= $matrix[$i][$j-1];
		$matrix[$i][$j]= max_pos($diag,$u,$l);#getting positions using max_pos subroutine
		if ($matrix[$i][$j] == 1) {
        	unshift @alignment1,(substr($firstseq, $j-1, 1));#unshift to add to first position
        	unshift @alignment2,(substr($secondseq, $i-1, 1));
        	$i=$i-1;
        	$j=$j-1;
		}
		elsif ($matrix[$i][$j] == 2) {
        unshift @alignment1,(substr($firstseq, $j-1, 1));
        unshift @alignment2,($dash);
        $j--;
    	}
    	elsif ($matrix[$i][$j] ==3 ) {
        unshift @alignment1,($dash);
        unshift @alignment2,(substr($secondseq, $i-1, 1));
        $i--;
    	}    
		
	}

} while $matrix[$i][$j]!=0;#doing this till we reach the 0,0 of the matrix

my @array;

for (my $c=0; $c<=$#alignment1; $c++){
	if ($alignment1[$c] eq $alignment2[$c]){
		push (@array, "|");#formatting the output
	}
	else {
		push (@array," ");
	}
}
print "@alignment1\n";
print "@array\n";
print "@alignment2\n";
$j= length($firstseq);
$i= length($secondseq);
print "Alignment Score:$matrix[$i][$j]\n";







