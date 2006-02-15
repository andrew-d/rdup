#!/bin/bash
#
# Copyright (c) 2005, 2006 Miek Gieben
# See LICENSE for the license
#
# inspired by yesterday of plan9

usage() {
        echo "$0 [OPTIONS] FILE [FILE ...]"
        echo
        echo Print/restore files from the dump
        echo
        echo FILE - look for this file in the backup dir
        echo
        echo OPTIONS
        echo " -n DAYSAGO  go back DAYSAGO days"
        echo " -b DIR      use DIR as the backup directory, YYYYMM will be added"
        echo " -k KEY      use the file KEY as decryption key"
        echo " -c          copy the backed up file over the current file"
        echo " -C          copy the backed up file over the current file, if they differ"
        echo " -d          show a diff with the backed up file "
        echo " -z          backup file is gzipped"
        echo " -h          this help"
}

## find the closest file to the one N days ago
## if there are multiple return the latest
## blaat           -n0 -> this one
## blaat+05:6:10   -n5 -> this one
## blaat+07:6:10   -n7 -> this one
recent() {
        if [[ $1 -ge 32 ]]; then return; fi

        for i in `seq $1 -1 0`; do
                suffix=`datesago $i`
                dayfix=${suffix:6:8}  # mshared.sh has the def.
                yyyymm=${suffix:0:6}
                # first check with suffix
                files=`ls "$backupdir"/$yyyymm/"$2"+$dayfix.* 2>/dev/null`
                if [[ ! -z $files ]]; then
                        echo $files | sort -n -r | head -1
                        return
                fi
        done
        files=`ls "$backupdir"/$yyyymm/"$2" 2>/dev/null`
        if [[ -z $files ]]; then
                return
        else
                echo $files | sort -n -r | head -1
                return
        fi
}

## calculate the date back in time $1 days ago
datesago() {
        echo `date --date "$1 days ago" +%Y%m%d` # YYYYMMDD
}


# default values
daysago=0
diff=0
keyfile=""
gzip=0
copy=0
Ccopy=0

while getopts ":n:b:k:cCNdhz" o; do
        case $o in
                b) backupdir=$OPTARG;;
                n) daysago=$OPTARG;;
                d) diff=1;;
                K) keyfile=$OPTARG;;
                z) gzip=1;;
                c) copy=1;;
                C) Ccopy=1;;
                h) usage && exit;;
                \?) usage && exit;;
        esac
done
if [ -z $backupdir ]; then
        backupdir="/vol/backup/`hostname`"
fi
shift $((OPTIND - 1))

for file in $@
do
        if [[ -z $file ]]; then
                continue
        fi
        if [[ ${file:0:1} != "/" ]]; then
                file=`pwd`/$file
        fi
        backupfile=`recent $daysago $file`

        # print
        if [[ $copy -eq 1 ]]; then
                cp -a $backupfile $file
                continue
        fi
        if [[ $Ccopy -eq 1 ]]; then
                cmp $backupfile $file > /dev/null
                if [[ $? ]]; then
                        cp -a $backupfile $file
                fi
                continue
        fi
        if [[ $diff -eq 1 ]]; then
                echo diff -u `basename $backupfile` `basename $file`
                if [[ $gzip -eq 1 ]]; then
                [[ ! -d $backupfile ]] && zcat $backupfile | diff -u - $file
                         continue;
                fi
                [[ ! -d $backupfile ]] && diff -u $backupfile $file
                continue
        fi

        echo $backupfile
done