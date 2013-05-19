#!/bin/bash
# print the max index of the list pages 

MAX_NUMBER=50000


low=30000
up=$MAX_NUMBER
mid=$(( (up+low)/2 ))

while(( (up - low) >= 2  ))
do
    echo $low "~" $up
    bookCount=$( ./sniffPage.sh $mid )
    if(( bookCount > 0 ))
    then
	low=$mid
    else
	up=$mid
    fi
    mid=$(( (up+low)/2 ))
done
echo
echo $mid
