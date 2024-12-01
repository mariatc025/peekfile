#!/usr/bin/env bash


## fastacan.ai.sh
## Improvements made:
# Added the possibility of finding an empty or incorrectly formated fa or fasta file (number of sequences is 0).
# Quoted variables which store filenames or filepaths, so that if they contain spaces they are handled correctly. Ex: $1, $folder and $i
# Made report title and file headers of equal length, regardless of the length of the folder name or file name.


## Argument 1 check
if [[ -z "$1" ]]  # check if $1 is empty
then
	folder=. # if it is empty set current folder as default
elif  [[ -d "$1" ]] # if it is not empty check if arg1 is a folder
then 
	folder="$1" # if arg1 is a folder assign it to $folder
else
	echo "Error!! Argument 1 is not a folder."
	exit 1     # else print the error message and exit the program
fi

## Argument 2 check
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

# Important variables:
FILES=$(find "$folder" -name "*.fasta" -or -name "*.fa" ) # finds fasta or fa files in folder and sub-folders,
							# and stores them in $FILES (in a single line)
N_FILES=$(echo $FILES| wc -w) # counts how many files it has found. If $FILES is empty the output will be 0.

# Improved readability in report:
if [[ $folder == . ]] # if $folder is a . 
then folder="the current folder" # changes it to "the current folder" improving readability in the report
fi

# Title:
echo # new_line
# To obtain a report title with length 100 regardless of the length of the folder name:
header_length=100 # total title length
title=$(echo "FASTA/FA files in" "$folder" "REPORT") # string that will be in the title
title_length=$(echo $title | awk '{print length($0)}') # length of the string
padding_one_side_length=$((($header_length - $title_length)/2)) # length that each side of the padding should have
for ((j=1; j<=$padding_one_side_length; j++))
do 
	padding_one_side+="#" # string of "#" * one_side_padding_length
done
echo $padding_one_side $title $padding_one_side # printed full title
echo # new_line


if [[ $N_FILES -gt 0 ]] # checks if at least 1 fa or fasta file was found
then
	## How many fasta or fa files there are
	if [[ $N_FILES -eq 1 ]]
	then echo "There is $N_FILES fasta or fa file inside $folder."
	else echo "There are $N_FILES fasta or fa files in $folder."
	fi
	
	## How many unique IDs there are
	ID_total=$(awk '/^>/{print $1}' $FILES | sort | uniq -c | wc -l) # finds the lines beginning with > prints the id, 
									 # sorts them and counts how many unique IDs there are					
	if [[ $ID_total -eq 1 ]]						 
	then echo "There is $ID_total unique fasta ID." # not likely, but prints this when there is only one unique fasta ID
	else echo "There are $ID_total unique fasta IDs."
	fi
	echo # new_line
	
	# for each file
	for i in $FILES
	do 

		## Filename Header
		# To obtain a header title with length 100 regardless of the length of the file full name:
		header_length=100 # total title length
		file_length=$(echo $i | awk '{print length($0)}') # length of the file full name
		padding_one_side_length=$((($header_length - $file_length)/2)) # length that each side of the padding should have
		padding_one_side="" # to restart the variable from nothing every time
		for ((j=1; j<=$padding_one_side_length; j++))
		do 
			padding_one_side+="=" # string of "=" * padding_one_side_length
		done
		echo $padding_one_side $i $padding_one_side # printed full header
		
		## Is the file a symlink or not
		if [[ -L "$i" ]] 
		then
			echo "Type symlink: Yes"
		else
			echo "Type symlink: No"
		fi
		
		## Number of sequences per file
		N_SEQ=$(awk '/^>/{print $1}' "$i" | wc -l) # prints the IDs of the file and counts them and stores it in $N_SEQ
		
		if [[ $N_SEQ -eq 0 ]] # checks if the file is empty or incorrectly formatted.
		then 
			echo "Number of sequences: 0"
			echo "The fasta or fa file is empty or the content is not in the correct FASTA format."
			echo # new_line
			continue # skips to the next file
		else
			echo "Number of sequences: $N_SEQ"
		fi
		
		## Total sequence length per file, without -," " and \n
		T_SEQ_L=$(awk '!/>/{gsub(/-/, "", $0); gsub(" ", "", $0); total_length += length($0)} END {print total_length}' "$i") 
		# finds the lines with no >, deletes - and spaces, counts the length per line and adds it to total length, which is stored in $T_SEQ_L
		echo "Total sequence length: $T_SEQ_L"
		
		## Sequences content: nucleotide or amino acids
		ACTG_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' "$i" | grep -o '[actgACTG]' | wc -l) # finds the lines with no >, deletes -, and from those
										# lines greps the letters actg (case insensitive) and counts how many there are
		TOTAL_counts=$(awk '!/>/{gsub(/-/, "", $0); print $0}' "$i" | grep -o '[^ ]' | wc -l) # finds the lines with no >, deletes -, and from those
										# lines greps all the characters except spaces and counts how many there are
		
		ACTG_freq=$(( ($ACTG_counts*100) / $TOTAL_counts )) # calculates the frequency of ACTG in the sequence,
								    # multiplies first because this expansion is integer only and by changing the order we 
								    # would always get 0
		if [[ $ACTG_freq -gt 70 ]] # if the frequency is greater than 70 they are nucleotides. Protein sequences usually have ACTG with a frequency
					   # less than 50%. We don't put 100% because there is the possibility of other IUPAC characters such as N.
		then
			echo "Sequences content: nucleotides"
		else
			echo "Sequences content: amino acids"
		fi
		
				
		## Prints the full file or the beginning and ending, only if arg2 is not 0
		FILE_lines=$(cat "$i" | wc -l) # counts number of lines in the file
		if [[ $N != 0 ]] # only done if arg2 is not 0
		then
			echo # new_line
			if [[ $FILE_lines -le $((2*$N)) ]]; 
			then
				cat "$i" # prints the whole file if FILE_lines <= 2*arg2
			else
				head -n $N "$i" # otherwise it prints the first N lines and the last N lines
				echo ...
				tail -n $N "$i"
			fi
		fi
		echo
	done
	
else # no fa or fasta files found
	echo "There are 0 fasta or fa files in $folder."
	echo # new_line
fi


