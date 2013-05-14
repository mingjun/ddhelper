#!/bin/bash
TARGET_FILE=./ddbook.list
LOG_FILE=./ddcrawler.log
SLEEP_TIME=0.25

CATEGORY=01.54.24.00.00.00

SITE_URL="http://category.dangdang.com/all/?category_path=01.54.24.00.00.00&filter=0%7C0%7C1%7C0&page_index"
COUNT=1

TRY_FILE=/tmp/dd.try.html
TEMP_FILE=/tmp/dd.tmp.html


touch $TRY_FILE
touch $TEMP_FILE

for i in `seq $COUNT`
do
    sleep $SLEEP_TIME


    echo crawl page No.$i
    # download
#    curl $SITE_URL"=$i" > $TRY_FILE
    
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

    cat $TEMP_FILE | hxselect -s "\n\n\n" ".shoplist>ul>li" |awk 'BEGIN {RS="\n\n\n"} {gsub(/[ \t\n\r]+/,  " FIXME "); print}'|\
    while read line
    do
	each_li=$( echo $line | hxclean )
	book_link=$( echo $each_li | hxselect ".name a" )

	if [ -z "$book_link" ]
	then
	    echo "!!!" $line
	    continue
	fi

	book_name=$( echo $book_link | awk '{gsub(/<[^>]+>/, "")} {print}' )
	echo $book_name

    done
#    book_name=$( cat $TEMP_FILE | hxselect "[name=Title_pub] h1" | awk '{gsub("<[^>]+>", ""); print}' )
#    price=$( cat $TEMP_FILE | hxselect "#d_price" | awk '{gsub("<[^>]+>", ""); sub("&yen;", ""); print}' )
#    pprice=$( cat $TEMP_FILE | hxselect ".m_price" | awk '{gsub("<[^>]+>", ""); sub("&yen;", ""); print}' )
#    printf "%s\t%s\t%s\t%s\n" $price $pprice $pid "$book_name" >> $TARGET_FILE
done
