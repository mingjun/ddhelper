#!/bin/bash

START_INDEX=$1
END_INDEX=$2

# load config file
source ./ddhelper.conf
# here we have URL_PATTERN

seq $START_INDEX $END_INDEX | \
    awk -v pat=$URL_PATTERN '{printf pat"\n" , $1 }' \
    > download.list
