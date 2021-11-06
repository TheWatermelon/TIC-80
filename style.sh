#!/bin/bash

FILENAME=$1
TOTAL_LINES=$(wc -l $FILENAME | awk '{print $1}')
END_HEADER=$(grep -n '</head>' $FILENAME | awk -F ':' '{print $1}')
LINE_NUMBER=$[ $END_HEADER - 1 ]
LINE_TO_ADD='<link rel="stylesheet" src="stylesheet.css">'
REMAINING_LINES=$[ $TOTAL_LINES - $LINE_NUMBER ]

CMD='sed -i '"'"$LINE_NUMBER'i<link rel="stylesheet" href="stylesheet.css" />'"' "$FILENAME

#$CMD
head -n $LINE_NUMBER $FILENAME > .tmp
echo $LINE_TO_ADD >> .tmp
tail -n $REMAINING_LINES $FILENAME >> .tmp

mv .tmp $FILENAME


