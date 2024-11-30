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
FILES=$(find $folder -name "*.fasta" -or -name "*.fa" )
NFILES=$(echo $FILES| wc -w)
if [[ $NFILES -gt 0 ]]
then 
	echo "There are $NFILES fasta or fa files in $folder."  ## 1 file?
	
	IDtotal=$(awk '/^>/{print $1}' $FILES| sort | uniq -c | wc -l)
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
		echo "Number of sequences: $(awk '/^>/{print $1}' $i| wc -l)"
		echo "Total sequence length: $(awk '!/>/{gsub(/-/, "", $0);gsub(" ", "", $0); total_length += length($0)} END {print total_length}' $i)"
		echo	
	done
	
	
else
	echo "There are 0 fasta or fa files in $folder."
fi


