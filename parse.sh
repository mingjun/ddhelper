#!/bin/bash

INPUT_FILE=/tmp/dd.raw.html

TARGET_FILE=ddbook.list
LOG_FILE=parse.error.log

TEMP_FILE=/tmp/dd.tmp.html
MATRIX_TEMP=/tmp/dd.tmp.matrix

######################
AWK=gawk
#####################

#normalize the product page
cat $INPUT_FILE | hxclean 1>$TEMP_FILE 2>/dev/null

# parse info
product_link=$( cat $TEMP_FILE | hxselect ".maintitle>a" 2> /dev/null )
# check blank(end)
if [ $( echo $product_link | wc -w) -eq 0 ]
then
    echo "parse failed for " $INPUT_FILE
else

    cat $TEMP_FILE | hxselect -cs "\n" ".tiplist .price_d em" 2> /dev/null 1> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    cat $TEMP_FILE | hxselect -c ".tiplist .price_m" 2> /dev/null | $AWK 'BEGIN {RS="&yen;"}; /.+/ {print $1}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    echo $product_link | $AWK 'BEGIN {RS="</a>"};/product_id=/ {match($0, /product_id=[0-9]+/);str=substr($0, RSTART, RLENGTH); gsub("product_id=","", str); print str}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    echo $product_link | $AWK '{gsub("[ ]*<[^>]+>[ ]*", "\t"); print}' | $AWK 'BEGIN {RS="[\t]+"}; /.+/ {gsub(/[ ]+/ , "-"); print $1}' >> $MATRIX_TEMP

    # append to target file
    cat $MATRIX_TEMP | $AWK -f ./matrixT.awk >> $TARGET_FILE

fi
