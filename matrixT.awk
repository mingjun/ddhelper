# Matrix Transpose
BEGIN {
    RS="\n\n"
    FS="\n"
    OFS="\t"
}

{
    for(i=1; i <= NF; i++) {
	m[FNR,i]=$i
    }
}

END {
    for(i=1; i<=NF; i++) {
	for(j=1; j <= FNR; j++) {
	    printf "%s%s", m[j, i], OFS
	}
	print ""
    }
}
