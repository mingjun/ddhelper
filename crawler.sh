#!/bin/bash

wget  --load-cookies cookies.txt \
    --save-cookies cookies1.txt --keep-session-cookies \
    --limit-rate=512k \
    -i download.list  -nv -o out/wget.log \
    -O out/all.raw.html
