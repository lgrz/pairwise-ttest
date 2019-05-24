#!/bin/bash

# Perform pairwise t-test with Bonferroni correction

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMPA=$(mktemp -p .)
TMPB=$(mktemp -p .)
HEADER="qid"
COUNTER=0
SYSMAP="System mapping:"$'\n'

for i in $@; do
    name="Sys$COUNTER"
    SYSMAP="$SYSMAP  $name $(basename $i)"$'\n'
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

echo "$SYSMAP"
Rscript $SPATH/pairwise.r $TMPB
rm $TMPA $TMPB
