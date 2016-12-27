#!/bin/sh
#find /volume1/photo/ -type d -name @eaDir -exec rm -rfv "{}" \;

#ORIGIN="/volume2/files/"
ORIGIN="./"
TRASH="/volume2/data/TRASH/cleanup-$(date +%Y%m%d%H%M%S)"

mkdir -p "$TRASH"

echo "=== REMOVING @eaDir dirs from $ORIGIN"
i=0
find "$ORIGIN" -type d -name '@eaDir' | while read FILE
do
        #echo rm -v "$FILE"
	echo $i - "$FILE"
	mv "$FILE" "$TRASH/eadir-$i"
	i=$(($i + 1))
done
echo

echo "=== REMOVING .DS_Store dirs from $ORIGIN"
i=0
find "$ORIGIN" -type d -name '.DS_Store' | while read FILE
do
        #echo rm -v "$FILE"
	echo $i - "$FILE"
	mv "$FILE" "$TRASH/dsstore-$i"
	i=$(($i + 1))
done
echo

