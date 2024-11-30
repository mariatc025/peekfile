#!/usr/bin/env bash

## Argument 1 check:
 
if [[ -z $1 ]]  # check if $1 is empty
then
	folder=. # if it is empty set current folder as default
elif  [[ ! -d $1 ]] # if it is not empty check if the argument is a folder
then 
	echo "Error!! Argument 1 is not a folder"
else
	folder=$1 # if arg1 is a folder assign it to $folder
fi

## Argument 2 check:
if [[ -z $2 ]]  # check if $2 is empty
then
	N=0 # if it is empty set number of lines to 0
elif  [[ $2 =~ "^[0-9]+$" ]] # if it is not empty check if the arg2 is numeric
then 
	N=$2 # if arg2 is numeric assign it to $N
	
else
	echo "Error!! Argument 2 is not numeric"
fi


## Report
FILES=$(find $folder -name "*.fasta" -or -name "*.fa" ) # finds fasta or fa files in $folder and stores them in $FILES (in a single line)
NFILES=$(echo $FILES| wc -w) # couts how many files it has found

if [[ $NFILES -gt 0 ]]
then
	if [[ $NFLIES -eq 1 ]]
	then 
		echo "There is $NFILES fasta or fa file in $folder."
	else
		echo "There are $NFILES fasta or fa files in $folder."
	fi
	
	IDtotal=$(awk '/^>/{print $1}' $FILES | sort | uniq -c | wc -l)
	echo "There are $IDtotal unique fasta IDs"
	
	for i in $FILES
	do 
		echo "=========$i========="
		if [[ -L "$i" ]]
		then
			echo "Symlink: Yes"
		else
			echo "Symlink: No"
		fi
		NSEQ=$(awk '/^>/{print $1}' $i| wc -l)
		echo "Number of sequences: $NSEQ"
		
		TSEQL=$(awk '!/>/{gsub(/-/, "", $0); gsub(" ", "", $0); total_length += length($0)} END {print total_length}' $i) 
		echo "Total sequence length: $TSEQL"
		
		ACTG_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' $i | grep -o '[actgACTG]' | wc -l)
		total_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' $i | grep -o '[^ ]' | wc -l)
		if [[ ACTG_counts -gt 0 ]]
		then
			ACTG_freq=$(( ($ACTG_counts*100) / $total_counts )) # we multiply first because this expansion is integer only and changing the order we would always get 0
			if [[ $ACTG_freq -gt 70 ]] # it is not 100% because there is the possibility of other IUPAC characters such as N
			then
				echo "Sequences content: nucleotides"
			else
				echo "Sequences content: amino acids"
			fi
		else
			echo "Sequences content: amino acids"
		fi
		#if [[ $ACTG_freq -gt 70 ]]
		#then
		echo
		 
		
	done
	
	
else
	echo "There are 0 fasta or fa files in $folder."
fi


