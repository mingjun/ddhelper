#!/bin/bash
TARGET_FILE=./ddbook.list
LOG_FILE=./dderror.log
SLEEP_TIME=0.25

CATEGORY=01.54.24.00.00.00
COUNT=200

SITE_URL="http://category.dangdang.com/all/?category_path="$CATEGORY"&filter=0%7C0%7C1%7C0&page_index"

TRY_FILE=/tmp/dd.try.html
TEMP_FILE=/tmp/dd.tmp.html
MATRIX_TEMP=/tmp/dd.tmp.matrix

touch $TRY_FILE
touch $TEMP_FILE

for i in `seq $COUNT`
do
    sleep $SLEEP_TIME

    echo crawl page No.$i
    # download
    curl $SITE_URL"=$i" > $TRY_FILE
    
    #check page validation
    if [ $( cat $TRY_FILE | wc -w ) -eq 0 ] 
    then 
	echo $i " invalid page" >> $LOG_FILE
	continue
    fi

    #normalize the product page
    cat $TRY_FILE  | awk '/charset=/ {gsub(/(GB2312)|(gb2312)/, "UTF-8")} {print}' \
	| iconv -f GBK -t UTF-8 -c \
	| hxclean 2> /dev/null 1> $TEMP_FILE

    # parse info
    product_link=$( cat $TEMP_FILE | hxselect ".shoplist>ul>li .name a" )
    # check blank(end)
    if [ $( echo $product_link | wc -w) -eq 0 ]
    then
	echo $i " end"
	break
    fi

    cat $TEMP_FILE | hxselect -c ".shoplist>ul>li .price_n" | awk 'BEGIN {RS="&yen;"}; /.+/ {print $1}' > $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    cat $TEMP_FILE | hxselect -c ".shoplist>ul>li .price_r" | awk 'BEGIN {RS="&yen;"}; /.+/ {print $1}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP    
    echo $product_link | awk 'BEGIN {RS="</a>"};/product_id=/ {match($0, /product_id=[0-9]+/);str=substr($0, RSTART, RLENGTH); gsub("product_id=","", str); print str}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    echo $product_link | awk '{gsub("[ ]*<[^>]+>[ ]*", "\t"); print}' | awk 'BEGIN {RS="[\t]+"}; /.+/ {gsub(/[ ]+/ , "-"); print $1}' >> $MATRIX_TEMP

    # append to target file
    cat $MATRIX_TEMP | awk -f ./matrixT.awk >> $TARGET_FILE

done



