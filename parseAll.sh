#!/bin/bash

RAW_FILE=out/all.raw.html
SLICE_TARGET=/tmp/dd.raw.html

AWK=gawk

cat $RAW_FILE  | $AWK '/charset=/ {gsub(/(GB2312)|(gb2312)/, "UTF-8")} {print}' \
    | iconv -f GBK -t UTF-8 -c \
    | java SliceHtml "</html>" $SLICE_TARGET ./parse.sh
