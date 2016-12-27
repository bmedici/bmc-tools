#!/bin/bash

TARGET="/home/bruno/mysql2svn/mysql"
#DUMPFILE="$TARGET/marlin.sql"
MYSQLDUMP="mysqldump -c --extended-insert=false --compact --hex-blob -u backup"
MYSQL="mysql -u backup"
SVNADD="svn -q --force add"
HOST="`hostname`"

echo "* initializing"
NOW=$(date +%Y%m%d%H%M)
set -e
mkdir -p "$TARGET"
cd "$TARGET"


echo "* listing databases"
databases=`$MYSQL -e 'SHOW DATABASES;' | grep -Ev '(Database|information_schema|performance_schema)'`
#echo $databases

echo "* dumping databases to files"
#$MYSQLDUMP -A > "$DUMPFILE"
for db in $databases; do
	echo "  $db"
	dumpfile="$TARGET/$HOST.$db.sql"
	$MYSQLDUMP "$db" > "$dumpfile"
	$SVNADD "$dumpfile"
done


echo "* committing files to subversion repository"
#svn add "$DUMPFILE"
svn commit -m "mysqldump bubbles $NOW" "$DUMPFILE"


echo "* ended"
