#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Get total size of staged files
total=0
count=0
for filename in $(git diff --staged --name-only --relative)
do
	filesize=$(stat -f "%z" "$filename")
	total=$(($total + $filesize))
	count=$(($count + 1))	
done
echo "staged ..... $(($total /1024)) KB, $count file(s)"

# Get total size of staged files
total=0
count=0
for filename in $(git ls-files -o)
do
	filesize=$(stat -f "%z" "$filename")
	count=$(($count + 1))	
	total=$(($total + $filesize))
done
echo "unstaged ... $(($total /1024)) KB, $count file(s)"

# End
IFS=$SAVEIFS

