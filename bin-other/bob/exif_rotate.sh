#!/bin/bash
total=$#
current=0
percent=0

(
while [[ -n "$1" ]]; do
	# update progress bar
	percent=`expr 100 \* $current / $total`
	echo "$percent" ;
	echo "# Processing ($current/$total): $1 "
	#sleep 1

	# process current file, if a file and not a dir
	if [[ -f "$1" ]]; then
		jhead -autorot "$1"
		if [ "$?" = -1 ] ; then
			zenity --error --text="Processing failed"
		fi
	fi

	# go to next file
	shift
	$((current+=1))
done

echo "# DONE - $total files processed.";

) |
zenity --progress \
--title="Auto-rotating images" \
--text="Processing files ..." \
--percentage=0 --auto-kill 

