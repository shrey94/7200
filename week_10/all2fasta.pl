#!/usr/bin/perl 
use strict;
use warnings;

my $file = $ARGV[0];
unless (open (FILE, $file)) {
    print " file not in correct format \n";
    exit;
}

my @file_contents = <FILE>;#user input file STORING IN ARRAY
my @fields;

close(FILE);

$file =~ s/\..*//; #remove extension
foreach my $line (@file_contents)
{
	
	if($line =~ /^@/)#condition for fastq
	{
		
		convert_to_FASTQ(@file_contents);
		exit;
	}
	if($line =~ /^ID/)#condition for embl
	{
		
		convert_to_EMBL(@file_contents);
		exit;
	} 
	
	if($line=~ /^LOCUS/)#condition for genbank

	{	
		convert_to_GenBank(@file_contents);
		exit;
	}
	
	if($line=~  /^#mega/)#condition for mega
	{
		convert_to_MEGA(@file_contents);
		

		exit;
	}
	if($line =~ /^>/)#condition for PIR
	{
		convert_to_PIR(@file_contents);
		

		exit;
	}
}

############defining subroutines#############

sub convert_to_FASTQ{
	
	#my $line;
	foreach my $line (@file_contents){
		if($line =~ /^@/)
		{
			$line =~ s/@/>/g;#substituting for getting fasta
		
		}
		if($line=~ /^[A-Z|a-z]/){
			$line =~ s/\.+/N/g;#substituting the dots with N
			

		}

	}
	
		if($file_contents[1] =~ /^[ATGC|atgc]+/) 
		{
			open(OUTPUT,'>',$file. ".fna");#condition for nucleic acid
			
		}
		else
		{
			open(OUTPUT,'>',$file. ".faa");
			
		}
	
	# print OUTPUT "$file_contents[0]";{

	

	for (my $i=1; $i<$#file_contents ;$i=$i+4){#printing lines 2,6,10 etc
		print OUTPUT "$file_contents[$i-1]";
		print OUTPUT "$file_contents[$i]";
	}

	#close(OUTPUT);
}

sub convert_to_EMBL{	
	

	open(OUTPUT,'>',$file. ".fna");#EMBL has only nucleic acid seqs
	
	foreach my $line (@file_contents){
		if ($line =~ /^ID/)
		{
			$line =~ s/^ID\s+/>/;#substituting for getting fasta format
			chomp($line);
			print OUTPUT $line;
		}
		if($line =~ /^AC/)#AC has accession number
		{
			$line =~ s/^AC\s+//;
			print OUTPUT $line;

		}
		if ($line =~ /^\s+/)
		{
			$line=~ s/\s//g;
			$line=~ s/[0-9]*//g;#removing the numbers
			$line=~ tr/atcg/ATCG/;#uppercase
			print OUTPUT $line;
		}


	}
	#close (OUTPUT);
}

sub convert_to_GenBank{
	foreach my $line (@file_contents)
	{
		if($line =~ /^LOCUS/)
		{
			if($line =~ /.*aa.*/)#looking for aa
			{
				
				open(OUTPUT,'>',$file. ".faa");
				
			}
			else
			{
				open(OUTPUT,'>',$file. ".fna");
				
			}
		}
	}

	foreach my $line (@file_contents){
		if($line =~ /^LOCUS/)
			{
				$line =~ s/^LOCUS\s+/>/;#getting the locus line for accession number
				$line=~ s/\s+/ /g;

				chomp $line;
				print OUTPUT $line;
			}

		if ($line=~ /^\s+[0-9]+\s/){#space search for sequences
			$line =~ s/\s+//g;
			$line=~ s/[0-9]*//g;

			print OUTPUT "\n";
			print OUTPUT $line;
		}

	}

}

sub convert_to_MEGA{
	

	foreach my $line(@file_contents)
	{
		if($line =~ /^#mega/)
		{
			
			if($line =~ /[acgt|ACGT]+/)
			{	
				open(OUTPUT,'>',$file.".fna");
				
			}
			else
			{
				open(OUTPUT,'>',$file.".faa");
				
			}
		}		
	}
	my %hash;
	foreach my $line(@file_contents)
	{
		if($line =~ /^#/)
		{
			$line =~ s/#mega//g;#removing mega and replacing with >
			$line=~ s/#/>/g;
		}
			
		if ($line =~ /^TITLE/)
		{
			
			$line=~ s/^TITLE.*//g;#removing the TITLE line
			
		}
		if ($line =~ /^TITLE/)
		{
			
			$line=~ s/^TITLE.*//g;
			
		}
		
	}	
	foreach my $line (@file_contents)
	{
		my @sequences = split(/\s+/,$line);#splitting on splace plus
			if (scalar(@sequences) >1){#condition given as some fields are empty
			
				if(!exists($hash{$sequences[0]}))
				{
					$hash{$sequences[0]} = $sequences[1];#adding new value to sequences
				}
				else
				{
				$hash{$sequences[0]} = $hash{$sequences[0]}.$sequences[1];#if already there then concatenating it with the next one
				}
		
			}
	}
	foreach my $name(sort keys %hash)
	{
		print OUTPUT $name,"\n",$hash{$name},"\n";
	}
	
			
}

sub convert_to_PIR{
	foreach my $line (@file_contents)
	{
		if($line=~/^[A-Z|a-z]/)
		{
			if ($line=~ /[D-FH-SU-Z|d-fh-su-z]*/)#looking for all amino acid letters except ATGC
			{
				#print $line;
				open(OUTPUT,'>',$file.".faa");
			}
		
		
			elsif($line =~ /[ACTG|actg]*/)#then looking for only ATGC for nucleotide
			{	
				#print $line;
				open(OUTPUT,'>',$file.".fna");
		
			}
		}
	}


	foreach my $line (@file_contents)
	{


		if($line=~/\*$/)#removing the *
		{
			$line=~s/\*//;
		}
		if($line =~ /^>[A-Z][0-9]*/)
		{	
			
			$line =~ s/>[A-Z][0-9]*;/>/;#removing the P1 and ; and replacing with > for fasta format
			$line =~ s/\n/ /;#removing the newline to get the next line
			
		}

	}

	print OUTPUT @file_contents;#printing to the output file
}