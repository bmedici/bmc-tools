backup_rsync () {
	# initializing
	local name="$1"
	local source="$2"
	local rsyncopt_common="$RSYNC_OPT"
	local rsyncopt_remote="$RSYNC_OPT --progress"
	local latest_dir="$BACKUPDIR/$name/latest"
	local target_dir="$BACKUPDIR/$name/$group/$(date +%Y.%m\ %B)/$name.$dfull"
	local temp_dir="$target_dir.tmp"

	status ""
	status "######################################################"
	status "## BACKUP"
	status "## name     $name"
	status "## group    $group"
	status "## source   $source"
	status "## snap     $latest_dir"
	status "## target   $target_dir"
	status "######################################################"

	# rsync parameters
	if [ $RSYNC_VERBOSE = 1 ]; then
		rsyncopt_remote="$rsyncopt_remote --verbose --progress"
	fi
	if [ $RSYNC_COMPRESS = 1 ]; then
		rsyncopt_remote="$rsyncopt_remote --compress"
	fi
	if [ $RSYNC_BWLIMIT != 0 ]; then
		rsyncopt_remote="$rsyncopt_remote --bwlimit=$RSYNC_BWLIMIT"
	fi

	# Make target dir
	status "making temp directory <$temp_dir>"
	mkdir -p "$temp_dir" ||
	#terminate "error creating target directory" || return;

	# Update local snapshot
	status "snapshotting $name/$group ($source)... "
	echo -n "Snapshotting $name/$group ($source)... "
	echo -n "updating... "
	#echo -n "updating [rsync <$source> <$latest_dir>] "
	(rsync "$source" "$latest_dir" $rsyncopt_remote >> $LOGFILE) ||
		terminate "snapshot: rsync error" || return

	# make final snapshot
	status "replicating final snapshot"
	echo -n "snapshotting... "
	#echo -n "snapshotting [rsync <$latest_dir> <$temp_dir> ] "
	mkdir -p "$temp_dir" ||
		terminate "error creating target dir" || return
	# > $LOGFILE 
	(rsync "$latest_dir"/ --link-dest="$latest_dir"/ "$temp_dir"/ $rsyncopt_common) ||
		terminate "replication: rsync error" || return

	# renaming final snapshot
	status "renaming final snapshot"
	echo -n "renaming... "
	#echo -n "renaming [mv <$temp_dir> <$target_dir> ] "
	mv "$temp_dir" "$target_dir"
		

	# end
	status "terminated"
	echo "done!"
	return 0;
	}


backup_mysql () {
	# initializing
	local name="$1"
	local target="$2"
	local user="$3"
	local extra="$4"
	#local latest_dir="$BACKUPDIR/$name/latest"
	#local target_dir="$BACKUPDIR/$name/$group/$(date +%Y.%m\ %B)/$name.$dfull"
	#local temp_dir="$target_dir.tmp"
	local temp_file="/tmp/mysqldump-$(date +%Y%m%d-%H%M%S).tmp"
	local target_file="`getbackupbase $name $group`.sql"
	local target_dir="`dirname \"$target_file\"`"
	
	
	status ""
	status "######################################################"
	status "## BACKUP"
	status "## name     $name"
	status "## group    $group"
	status "## user   	$user"
	status "## dir      $target_dir"
	status "## temp     $temp_file"
	status "## target   $target_file"
	status "######################################################"
	#return;
	
	# Make target dir
	status "making target directory"
	mkdir -p "$target_dir" ||
		terminate "error creating target directory" || return;

	# dump database
	echo -n "Dumping database $name/$group... "
	echo -n "dumping... "
	status "dumping remote database"
	(ssh -C $target mysqldump -c -e -A -u $user $MYSQL_OPT > $temp_file) ||
		terminate "mysqldump error" || return
	
	# rename temp file
	echo -n "renaming... "
	status "renaming temp file"
	(mv "$temp_file" "$target_file") ||
		terminate "rename error" || return
	
	# compress the dump
	status "compressing file"
	echo -n "compressing... "
	bzip2 "$target_file" ||
		terminate "bzip2 failed" || return
	
	# end
	status "terminated"
	echo "done."
	return 0;
	}


getbackupbase () {
	dfull=$(date +%Y%m%d-%H%M%S)
	dyear=$(date +%Y)
	dmonth=$(date +%m\ %B)
	dday=$(date +%d\ %A)
	name=$1
	group=$2
	echo "$BACKUPDIR/$name/$group/$(date +%Y.%m\ %B)/$name.$(date +%Y%m%d-%H%M%S)"
	
	}


terminate () {
	echo "$0 quitting: $1"
	return 1;
	}

status () {
	echo "* $1" >> $LOGFILE
	}

tunnel () {
	remote=$1
	localport=$2
	status "Building SSH tunnel ($remote, $localport)"
	ssh $remote -L:$localport:localhost:873 -C -o BatchMode=yes -f sleep 10
	if [ "${?}" -ne "0" ]; then
		terminate "ssh tunnel: unable to establish tunnel"
		exit 1
	fi
	}

