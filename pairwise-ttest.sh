#!/usr/bin/env bash

# Perform pairwise t-test with Bonferroni correction

SPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMPA=$(mktemp -p .)
TMPB=$(mktemp -p .)
HEADER="qid"
COUNTER=0
SYSMAP="System mapping:"$'\n'
PREV=""

err() {
    echo "$1" 1>&2
}

check_topic_count() {
    local prev=$1
    local curr=$2
    local prev_len=$(wc -l $prev | awk '{print $1}')
    local curr_len=$(wc -l $curr | awk '{print $1}')
    if [ $prev_len -ne $curr_len ]; then
        err "error: different number of topics found"
        err "$prev_len    $(basename $prev)"
        err "$curr_len    $(basename $curr)"
        exit 1
    fi
}

for i in $@; do
    name="Sys$COUNTER"
    SYSMAP="$SYSMAP  $name $(basename $i)"$'\n'
    HEADER="$HEADER $name"
    if [ $COUNTER -eq 0 ]; then
        cat $i > $TMPA
    elif [ $((COUNTER % 2)) -eq 0 ]; then
        check_topic_count $PREV $i
        join $TMPB $i > $TMPA
    else
        check_topic_count $PREV $i
        join $TMPA $i > $TMPB
    fi
    COUNTER=$((COUNTER + 1))
    PREV=$(basename $i)
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
