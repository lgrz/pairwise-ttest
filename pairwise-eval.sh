#!/bin/bash

# Evaluate run files into common format for pairwise t-test.

GDEVAL=gdeval.pl
TRECEVAL=trec_eval

usage() {
    echo "usage: $0 <metric> <cutoff> <qrels> file..." 1>&2
    exit 1
}

err() {
    echo "error: $1" 1>&2
    exit 1
}

eval_ndcg() {
    local cutoff=$1
    local qrels=$2
    local run=$3
    printf -v suffix "ndcg%02d\n" $cutoff
    $GDEVAL -k $cutoff $qrels $run \
        | sed -e 1d -e \$d \
        | awk -F, '{print $2, $3}' > ${run}.${suffix}
}

eval_err() {
    local cutoff=$1
    local qrels=$2
    local run=$3
    printf -v suffix "err%02d\n" $cutoff
    $GDEVAL -k $cutoff $qrels $run \
        | sed -e 1d -e \$d \
        | awk -F, '{print $2, $4}' > ${run}.${suffix}
}

eval_map() {
    local cutoff=$1
    local qrels=$2
    local run=$3
    printf -v suffix "map%04d\n" $cutoff
    $TRECEVAL -nq -m map_cut.$cutoff $qrels $run \
        | awk '{print $2, $3}' > ${run}.${suffix}
}

if [ $# -ne 4 ]; then
    usage
    exit 1
fi

case "$1" in
    ndcg)
        EVALFUNC=eval_ndcg; shift
        ;;
    err)
        EVALFUNC=eval_err; shift
        ;;
    map)
        EVALFUNC=eval_map; shift
        ;;
    *)
        err "unknown metric $1"
        ;;
esac

cutoff_arg=$1; shift
qrels_arg=$1; shift

for i in $@; do
    $EVALFUNC $cutoff_arg $qrels_arg $i
done
