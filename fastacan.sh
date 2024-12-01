#!/usr/bin/env bash

## Argument 1 check:
if [[ -z $1 ]]  # check if $1 is empty
then
	folder=. # if it is empty set current folder as default
elif  [[ -d $1 ]] # if it is not empty check if arg1 is a folder
then 
	folder=$1 # if arg1 is a folder assign it to $folder
else
	echo "Error!! Argument 1 is not a folder."
	exit 1     # else print the error message and exit the program
fi

## Argument 2 check:
if [[ -z $2 ]]  # check if $2 is empty
then
	N=0  # if it is empty set number of lines to 0
elif  [[ $2 =~ ^[0-9]+$ ]] # if it is not empty check if arg2 is numeric
then 
	N=$2 # if arg2 is numeric assign it to $N
else
	echo "Error!! Argument 2 is not numeric." 
	exit 1     # else print the error message and exit the program
fi


## REPORT
FILES=$(find $folder -name "*.fasta" -or -name "*.fa" ) # finds fasta or fa files in folder and subfolders and stores them in $FILES (in a single line)
N_FILES=$(echo $FILES| wc -w) # couts how many files it has found

if [[ $folder == . ]] # if $folder is a . 
then folder="the current folder" # changes it to "the current folder" improving readability in the report
fi


if [[ $N_FILES -gt 0 ]] # checks if at least 1 fa or fasta file was found
then
	## How many fasta or fa files there are
	if [[ $N_FILES -eq 1 ]]
	then echo "There is $N_FILES fasta or fa file inside $folder."
	else echo "There are $N_FILES fasta or fa files in $folder."
	fi
	
	## How many unique IDs there are
	ID_total=$(awk '/^>/{print $1}' $FILES | sort | uniq -c | wc -l) # finds the lines beggining with > prints the id, sorts them and counts how many unique IDs there are
	echo "There are $ID_total unique fasta IDs."
	
	## for each file
	for i in $FILES
	do 
		# filename
		echo "=========$i========="
		
		# If the file is a symlink or not
		if [[ -L "$i" ]] 
		then
			echo "Symlink: Yes"
		else
			echo "Symlink: No"
		fi
		
		# Number of sequences per file
		N_SEQ=$(awk '/^>/{print $1}' $i| wc -l) # prints the IDs of the file and counts them and stores it in $NSEQ
		echo "Number of sequences: $N_SEQ"
		
		# Total sequence length per file, without -," " and \n
		T_SEQ_L=$(awk '!/>/{gsub(/-/, "", $0); gsub(" ", "", $0); total_length += length($0)} END {print total_length}' $i) # finds the lines with no >, replaces - and spaces, counts the length per line and adds it to total length, which is stored in $TSEQL
		echo "Total sequence length: $T_SEQ_L"
		
		# Sequences content: nucleotide or amino acids
		ACTG_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' $i | grep -o '[actgACTG]' | wc -l) # finds the lines with no >, replaces -, and from those lines greps the letters actg (case insensitive) and counts how many there are
		TOTAL_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' $i | grep -o '[^ ]' | wc -l) # finds the lines with no >, replaces -, and from those lines greps all the characters except spaces and counts how many there are
		ACTG_freq=$(( ($ACTG_counts*100) / $TOTAL_counts )) # calculates the frequency of ACTG in the sequence
								    # multiplies first because this expansion is integer only and changing the order we would always get 0
		if [[ $ACTG_freq -gt 70 ]] # if the frequency is greater than 70 they are nucleotides. Protein sequences usually have ACTG with a frequency less than 50%
					   # we don't put 100% because there is the possibility of other IUPAC characters such as N.
		then
			echo "Sequences content: nucleotides"
		else
			echo "Sequences content: amino acids"
		fi
		
				
		# Prints the file or the begining and ending, only if arg2 is not 0
		FILE_lines=$(cat $i | wc -l) # counts number of lines in the file
		if [[ $N != 0 ]] # only done if arg2 is not 0
		then
			echo # new_line
			if [[ $FILE_lines -le $((2*$N)) ]]; 
			then
				cat $i # prints the whole file if FILE_lines <= 2*arg2
			else
				head -n $N $i # otherwise it prints the first N lines and the last N lines
				echo ...
				tail -n $N $i
			fi;
		fi;
		echo
	done
	
else # no fa or fasta files found
	echo "There are 0 fasta or fa files in $folder."
fi


