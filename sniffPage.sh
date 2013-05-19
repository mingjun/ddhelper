#!/bin/bash
# call me with a page index
# print a number
#     0     -- when got a blank page
#     1     -- when got a list

PAGE_INDEX=$1

# load config file
source ./ddhelper.conf
# here we have URL_PATTERN

URL=$( printf $URL_PATTERN $PAGE_INDEX )

#echo $URL
#echo page index is $PAGE_INDEX


wget  --load-cookies cookies.txt \
    --save-cookies cookies1.txt --keep-session-cookies \
    -qO - "$URL" | \
    grep --mmap -l 'class="tiplist"' | wc -l

#    grep 'class="tiplist' | wc -l
#    cat > test.html


#update cookie for next
#cp cookies1.txt cookies.txt
