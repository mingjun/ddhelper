#!/bin/bash

MAX_PAGE=0
BATCH_SIZE=100
#500

if(( $# > 0 ))
then
    MAX_PAGE=$1
else
    MAX_PAGE=$( ./findLastPage.sh | tail -n 1 )
fi

echo start downloading $MAX_PAGE pages 


for (( i=1; i<MAX_PAGE; i+=BATCH_SIZE ))
do
    #remove downloaded big file and log
    rm -f out/*

    start=$i
    end=$(( $i+$BATCH_SIZE-1 ))
    if(( $end > $MAX_PAGE ))
    then
	end=$MAX_PAGE
    fi

    echo downloading $start "~" $end
    ./planDownload.sh $start $end
    ./crawler.sh
    ./parseAll.sh
done
