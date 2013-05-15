#!/bin/bash
TARGET_FILE=out/ddbook.list
LOG_FILE=out/error.log
INTERVAL=0.25 #in seconds

CATEGORY=01.54.24.00.00.00
COUNT=200

SITE_URL="http://category.dangdang.com/all/?category_path="$CATEGORY"&filter=0%7C0%7C1%7C0&page_index"

TRY_FILE=/tmp/dd.try.html
TEMP_FILE=/tmp/dd.tmp.html
MATRIX_TEMP=/tmp/dd.tmp.matrix

######################
# define command / function
AWK=gawk
currentTimeInSecond () {
    # for GNU date, in nano, for others in second
    date "+%s.%N" | $AWK 'sub(".N", "")'
}
#####################

touch $TRY_FILE
touch $TEMP_FILE


for i in $( seq $COUNT )
do
    startTime=$( currentTimeInSecond )
    echo crawl page No.$i

    # download
    curl $SITE_URL"=$i" > $TRY_FILE 2>/dev/null
    
    #check page validation
    if [ $( cat $TRY_FILE | wc -w ) -eq 0 ] 
    then 
	echo $i " invalid page" >> $LOG_FILE
	continue
    fi

    #normalize the product page
    cat $TRY_FILE  | $AWK '/charset=/ {gsub(/(GB2312)|(gb2312)/, "UTF-8")} {print}' \
	| iconv -f GBK -t UTF-8 -c \
	| hxclean 2> /dev/null 1> $TEMP_FILE

    # parse info
    product_link=$( cat $TEMP_FILE | hxselect ".shoplist>ul>li .name a" )
    # check blank(end)
    if [ $( echo $product_link | wc -w) -eq 0 ]
    then
	echo "end"
	break
    fi

    cat $TEMP_FILE | hxselect -c ".shoplist>ul>li .price_n" | $AWK 'BEGIN {RS="&yen;"}; /.+/ {print $1}' > $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    cat $TEMP_FILE | hxselect -c ".shoplist>ul>li .price_r" | $AWK 'BEGIN {RS="&yen;"}; /.+/ {print $1}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP    
    echo $product_link | $AWK 'BEGIN {RS="</a>"};/product_id=/ {match($0, /product_id=[0-9]+/);str=substr($0, RSTART, RLENGTH); gsub("product_id=","", str); print str}' >> $MATRIX_TEMP
    echo "" >> $MATRIX_TEMP
    echo $product_link | $AWK '{gsub("[ ]*<[^>]+>[ ]*", "\t"); print}' | $AWK 'BEGIN {RS="[\t]+"}; /.+/ {gsub(/[ ]+/ , "-"); print $1}' >> $MATRIX_TEMP

    # append to target file
    cat $MATRIX_TEMP | $AWK -f ./matrixT.awk >> $TARGET_FILE

    # sleep if too quick
    endTime=$( currentTimeInSecond )
    sleepTime=$( echo "$INTERVAL - ($endTime - $startTime)" | bc )
    [ $( echo "$sleepTime > 0" | bc ) = 1 ] &&  sleep $sleepTime 
    
done



