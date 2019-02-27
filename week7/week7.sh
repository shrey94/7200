#!/bin/bash
#SNP calling Piepline
#defining usage function 
usage()
{
	echo -e "$0 [-a <Input_pair_1>][-b <Input_pair_2>][-r <Reference_genome_file> ][-o <Output_VCF_file_name>][-e <Perform_reads_realignment> ][-f <Mills_file_name>][-z <Output_gunzipped_VCF_file>][-v <Verbose>][-i <indexing> ][-h <instructions> ]" 
}

h=0

VERBOSE=0

read_realignment=0

indexing_bam=0

gunzip_out=0


#checking for no arguments 
if [ $# == 0 ]; then
	echo "Error! No arguments given" >&2
	exit 1
fi
#####################################################################
while getopts "a:b:r:o:ef:zvih" option; do
	case "$option" in 
		a)
		fastq_file1=$OPTARG

		
		;;

		b)
		fastq_file2=$OPTARG

		
		;;

		r)
		ref_genome_file=$OPTARG 

		
		;;

		o)
		Output_VCF_file_name=$OPTARG

		
		;; 

		e) read_realignment=1
		
		;;
		
		f)
		Mills_file_name=$OPTARG
		
		;;

		z) 
		gunzip_out=1 
		;;
		
		v)
		VERBOSE=1
		echo "Verbose mode on"
		;;

		i)
		indexing_bam=1

		;;

		h) h=1
			usage
			exit 1
	       ;;

	    *)
		usage
		exit 1
		;;
	esac 
done
#######checkpoints for file

if [ ! -e $fastq_file1 ]; 
	then
	echo -e "\nError1! " 
	exit 1 	
fi


if [ ! -f $fastq_file2 ]; 
	then
	echo -e "\nError2! " 
	exit 1 	
fi


if [ ! -f $ref_genome_file ]; 
	then
	echo -e "\nError1! " 
	exit 1 	
fi



if [ -f $Output_VCF_file_name ]; 
	then
#if present ask to overwrite
echo -e "$Output_VCF_file_name already present\nOverwrite (Yes-y/No-n)? " 
read userinput
#if overwrite permission not given, take another name
	if [ "$userinput" == "n" ]; 
		then
		exit 1						

		elif  [ "$userinput" == "y" ]; 
		then	
		rm $Output_VCF_file_name
	fi
fi			
############################# main code ##################################



####Burrows Wheeler aligner
if [ $VERBOSE == 1 ];
	then
		if [ $read_realignment == 1 ];
			then
			if [ ! -e $Mills_file_name ]; then
			echo -e "\nError 5 !"
			usage
			 
		fi
			echo -e "using Burrows Wheeler aligner. To prepare the reference for mapping you must first index it by typing the following command where $ref_genome_file is the your reference file"
			echo "This may take several hours"
			bwa index $ref_genome_file


			echo -e "mapping your reads to the reference"
			#finished preparing your indexed reference you can map your reads to the reference:
			bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref_genome_file  $fastq_file1  $fastq_file2 > lane.sam

			#BWA can sometimes leave unusual FLAG information on SAM records, it is helpful when working with many tools to first clean up read pairing information and flags:
			samtools fixmate -O bam lane.sam lane_fixmate.bam 

	
			echo -e "samtools sorting"
			#To sort them from name order into coordinate order:
 			samtools sort lane_fixmate.bam -O bam -o lane_fixmate_sorted.bam
			echo -e "samtools indexing"
			samtools index lane_fixmate_sorted.bam

			###improvement 
			echo -e "starting the improvement process using GATK in order to reduce the number of miscalls of INDELs in your data"

			echo -e "creating dict file"
			java -jar picard.jar CreateSequenceDictionary R=$ref_genome_file

			echo -e "creating fai file"
			samtools faidx $ref_genome_file
	
			echo -e "GATK usage : RealignerTargetCreator and IndelRealigner"
			java -Xmx2g -jar ./lib/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref_genome_file -I lane_fixmate_sorted.bam -o lane.intervals --known $Mills_file_name 
			java -Xmx4g -jar ./lib/GenomeAnalysisTK.jar -T IndelRealigner -R $ref_genome_file -I lane_fixmate_sorted.bam -targetIntervals lane.intervals -known $Mills_file_name -o lane_realigned.bam


			echo -e "samtools index for variant calling"
			if [ $indexing_bam == 1 ]; 
				then
				samtools index lane_realigned.bam
			fi
	

			##########variant calling
			echo -e "starting variant calling"
			if [ $gunzip_out == 1 ];
				then
				bcftools mpileup -Ou -f $ref_genome_file lane_realigned.bam | bcftools call -vmO z -o $Output_VCF_file_name
				else
				bcftools mpileup -Ou -f $ref_genome_file lane_realigned.bam | bcftools call -vmO v -o $Output_VCF_file_name
			fi

			echo -r "using tabix To prepare our VCF for querying"
			tabix -p vcf $Output_VCF_file_name

		elif [ $read_realignment == 0];
			then
			echo -e "using Burrows Wheeler aligner. To prepare the reference for mapping you must first index it by typing the following command where $ref_genome_file is the your reference file"
			echo "This may take several hours"
			bwa index $ref_genome_file


			echo -e "mapping your reads to the reference"
			#finished preparing your indexed reference you can map your reads to the reference:
			bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref_genome_file  $fastq_file1  $fastq_file2 > lane.sam

			#BWA can sometimes leave unusual FLAG information on SAM records, it is helpful when working with many tools to first clean up read pairing information and flags:
			samtools fixmate -O bam lane.sam lane_fixmate.bam 

	
			echo -e "samtools sorting"
			#To sort them from name order into coordinate order:
 			samtools sort lane_fixmate.bam -O bam -o lane_fixmate_sorted.bam

			echo -e "samtools indexing"
			samtools index lane_fixmate_sorted.bam


			echo -e "samtools index for variant calling"
			if [ $indexing_bam == 1 ]; 
			then
			samtools index lane_fixmate_sorted.bam
			fi
	

			##########variant calling
			echo -e "starting variant calling"
			if [ $gunzip_out == 1 ];
			then
			bcftools mpileup -Ou -f $ref_genome_file lane_fixmate_sorted.bam | bcftools call -vmO z -o $Output_VCF_file_name
			else
			bcftools mpileup -Ou -f $ref_genome_file lane_fixmate_sorted.bam | bcftools call -vmO v -o $Output_VCF_file_name
			fi

			echo -r "using tabix To prepare our VCF for querying"
			tabix -p vcf $Output_VCF_file_name

		
		fi


else

	if [ $read_realignment == 1 ];
		then
		if [ ! -e $Mills_file_name ]; then
			echo -e "\nError 5 !"
			usage
			 
		fi
			
			bwa index $ref_genome_file


			
			#finished preparing your indexed reference you can map your reads to the reference:
			bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref_genome_file  $fastq_file1  $fastq_file2 > lane.sam

			#BWA can sometimes leave unusual FLAG information on SAM records, it is helpful when working with many tools to first clean up read pairing information and flags:
			samtools fixmate -O bam lane.sam lane_fixmate.bam 

	
			
			#To sort them from name order into coordinate order:
 			samtools sort lane_fixmate.bam -O bam -o lane_fixmate_sorted.bam
			
			samtools index lane_fixmate_sorted.bam

			###improvement 
			
			java -jar picard.jar CreateSequenceDictionary R=$ref_genome_file

			
			samtools faidx $ref_genome_file
	
			
			java -Xmx2g -jar ./lib/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref_genome_file -I lane_fixmate_sorted.bam -o lane.intervals --known $Mills_file_name 
			java -Xmx4g -jar ./lib/GenomeAnalysisTK.jar -T IndelRealigner -R $ref_genome_file -I lane_fixmate_sorted.bam -targetIntervals lane.intervals -known $Mills_file_name -o lane_realigned.bam


			
			if [ $indexing_bam == 1 ]; 
				then
				samtools index lane_realigned.bam
			fi
	

			##########variant calling
			
			if [ $gunzip_out == 1 ];
				then
				bcftools mpileup -Ou -f $ref_genome_file lane_realigned.bam | bcftools call -vmO z -o $Output_VCF_file_name
				else
				bcftools mpileup -Ou -f $ref_genome_file lane_realigned.bam | bcftools call -vmO v -o $Output_VCF_file_name
			fi

			
			tabix -p vcf $Output_VCF_file_name

	elif [ $read_realignment == 0 ];
		then
			
		bwa index $ref_genome_file


			
		#finished preparing your indexed reference you can map your reads to the reference:
		bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref_genome_file  $fastq_file1  $fastq_file2 > lane.sam

		#BWA can sometimes leave unusual FLAG information on SAM records, it is helpful when working with many tools to first clean up read pairing information and flags:
		samtools fixmate -O bam lane.sam lane_fixmate.bam 

	
			
		#To sort them from name order into coordinate order:
 		samtools sort lane_fixmate.bam -O bam -o lane_fixmate_sorted.bam

			
		samtools index lane_fixmate_sorted.bam


			
		if [ $indexing_bam == 1 ]; 
		then
		samtools index lane_fixmate_sorted.bam
		fi
	

			##########variant calling
			
		if [ $gunzip_out == 1 ];
		then
		bcftools mpileup -Ou -f $ref_genome_file lane_fixmate_sorted.bam | bcftools call -vmO z -o $Output_VCF_file_name
		else
		bcftools mpileup -Ou -f $ref_genome_file lane_fixmate_sorted.bam | bcftools call -vmO v -o $Output_VCF_file_name
		fi
	
		tabix -p vcf $Output_VCF_file_name

	fi
fi