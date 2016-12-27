#!/bin/bash
max_size_mb=$1
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Init
if [ -z "$max_size_mb" ] ; then
	echo "usage: `basename $0` {max size in MB}"
	exit
fi
if [[ "$max_size_mb" = *[^0-9]* ]]
then
	echo "usage: `basename $0` {max size in MB - numeric values only}"
	exit 1
fi
if [ "$max_size_mb" -lt "1" ]
then
	echo "usage: `basename $0` {max size in MB - greater than 1 MB}"
	exit 1
fi
max_size=$(($max_size_mb*1024*1024))
count=0
echo "* max total: $(($max_size_mb)) MB"

# Get total size of staged files
staged_size=0
for filename in $(git diff --staged --name-only --relative)
do
	filesize=$(stat -f "%z" "$filename")
	staged_size=$(($staged_size + $filesize))
done
echo "* current staged total: $(($staged_size /(1024*1024))) MB"

# Evaluate size with more files
for filename in $(git ls-files --o)
do
	filesize=$(stat -f "%z" "$filename")
	future_size=$(($staged_size + $filesize ))	
	echo "* considering: $filename"
	if [ "$future_size" -lt "$max_size" ]
	then
		echo "  adding $(($filesize/1024)) KB"
		git add "$filename"
		staged_size=$future_size
	else
		echo "  not adding $(($filesize/1024)) KB - would exceed $max_size_mb MB limit"
		break 2
	fi
	#echo "  size is $current_file_size, total is $staged_size bytes, future is $future_size bytes, max is $max_size bytes"
done

# End
echo "* total staged is now $(($staged_size /(1024*1024))) MB"
IFS=$SAVEIFS
