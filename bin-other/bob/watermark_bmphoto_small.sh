#!/bin/bash
#
# watermark.sh
# $Id: watermark,v 1.1 2004/10/03 10:52:21 ullgren Exp $
#
# Add a defined watermark to a series of pictures
#

# Absolute Location of the Watermark file
WM="/home/bruno/watermark-bmphoto-small.png"

if [ ! -n "$1" ]
then
  zenity --error --text "Please select pics to be watermarked!"
  exit $E_BADARGS
fi

typeset -i CNT=1
typeset -i CUR=0

(
 for pic in "$@"
  do
    echo "#Watermarking $pic"

    composite -dissolve 40% -gravity SouthEast  -geometry +0+10 "$WM" "$pic" "$pic"

    CUR=$CNT*100/$#
    echo $CUR
    CNT=$CNT+1
    done
) | zenity --progress --auto-close --percentage=0
