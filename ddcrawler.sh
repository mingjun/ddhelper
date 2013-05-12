#!/bin/bash
TARGET_FILE=./ddbook.list
LOG_FILE=./ddcrawler.log
SLEEP_TIME=0.25

SITE_URL=http://product.dangdang.com/product.aspx?product_id
START_ID=22926318
COUNT=277000

TRY_FILE=/tmp/dd.try.html
TEMP_FILE=/tmp/dd.tmp.html


touch $TRY_FILE
touch $TEMP_FILE

for i in `seq $COUNT`
do
    sleep $SLEEP_TIME

    pid=$(( $i + $START_ID ))
    echo crawl product $pid
    # download
    curl $SITE_URL"="$pid > $TRY_FILE
    
    #check page validation
    if [ $( cat $TRY_FILE | wc -w ) -eq 0 ] 
    then 
	echo $pid "invalid id" >> $LOG_FILE
	continue
    fi
    
    #normalize the product page
    cat $TRY_FILE  | awk '/charset="gbk"/ {gsub(/gbk/, "UTF-8")} {print}' \
	| iconv -f GBK -t UTF-8 -c \
	| hxclean 2> /dev/null 1> $TEMP_FILE

    # parse info
    book_name=$( cat $TEMP_FILE | hxselect "[name=Title_pub] h1" | awk '{gsub("<[^>]+>", ""); print}' )
    price=$( cat $TEMP_FILE | hxselect "#d_price" | awk '{gsub("<[^>]+>", ""); sub("&yen;", ""); print}' )
    pprice=$( cat $TEMP_FILE | hxselect ".m_price" | awk '{gsub("<[^>]+>", ""); sub("&yen;", ""); print}' )

    # when pprice is invalid, set discount=100
    if [ $( echo "$pprice <= 0" | bc ) -eq 1 ]
    then
	discount=100
    else
	discount=$( echo "scale=2; $price*100/$pprice" | bc )
    fi

    printf "%s\t%s\t%s\t%s\t%s\n" $discount $price $pprice $pid "$book_name" >> $TARGET_FILE
done
