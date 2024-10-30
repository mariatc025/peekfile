#!/bin/bash

if [[ -n $2 ]];
then NLINES=$2;
else NLINES=3;
fi;

FLINES=$(cat $1 | wc -l)
if [[ $FLINES -le 2*$NLINES ]];
	then cat $1;
else
	echo Warning: not all lines are being displayed;
	head -n $NLINES "$1";
	echo ...;
	tail -n $NLINES "$1";
fi;
