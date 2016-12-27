#!/bin/sh

DEST="/data/kernel/pub/"
export RSYNC_PASSWORD="eqSiyOon"

rsync mirrors@filehub.kernel.org::pub $DEST \
	--verbose --recursive --times \
	--links --hard-links --delete --delete-after \
	--sparse --force \
	--exclude "/pub/dist"

#	--links --hard-links --compress --sparse
#	--exclude "*.gz" --exclude "*.gz.sign" --exclude "git" --exclude "scm" \
#	--exclude "*.gz" --exclude "*.gz.sign"

