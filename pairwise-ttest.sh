#!/bin/bash

# Perform pairwise t-test with Bonferroni correction

TMPA=$(mktemp -p .)
TMPB=$(mktemp -p .)
HEADER="qid"
COUNTER=0

for i in $@; do
    name=$(basename $i)
    HEADER="$HEADER $name"
    if [ $COUNTER -eq 0 ]; then
        cat $i > $TMPA
    elif [ $((COUNTER % 2)) -eq 0 ]; then
        join $TMPB $i > $TMPA
    else
        join $TMPA $i > $TMPB
    fi
    COUNTER=$((COUNTER + 1))
done

# flip the modulus, the counter was incremented on the last iteration
if [ $((COUNTER % 2)) -eq 0 ]; then
    cp $TMPB $TMPA
fi

echo $HEADER > $TMPB
cat $TMPA >> $TMPB

Rscript pairwise.r $TMPB > result.txt
rm $TMPA $TMPB
