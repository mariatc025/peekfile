if [[ -n $2 ]];
then NLINES=$2;
else NLINES=3;
fi;

head -n $NLINES "$1";
echo ...;
tail -n $NLINES "$1";
