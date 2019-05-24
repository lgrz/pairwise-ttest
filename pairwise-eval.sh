#!/usr/bin/env bash

# Evaluate run files into common format for pairwise t-test.

GDEVAL=gdeval.pl
TRECEVAL=trec_eval
RBPEVAL=rbp_eval

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
        | awk -F, '{print $2, $3}' \
        | sort -k1n > ${run}.${suffix}
}

eval_err() {
    local cutoff=$1
    local qrels=$2
    local run=$3
    printf -v suffix "err%02d\n" $cutoff
    $GDEVAL -j $MAXJ -k $cutoff $qrels $run \
        | sed -e 1d -e \$d \
        | awk -F, '{print $2, $4}' \
        | sort -k1n > ${run}.${suffix}
}

eval_map() {
    local cutoff=$1
    local qrels=$2
    local run=$3
    printf -v suffix "map%04d\n" $cutoff
    $TRECEVAL -nq -m map_cut.$cutoff $qrels $run \
        | awk '{print $2, $3}' \
        | sort -k1n > ${run}.${suffix}
}

eval_rbp() {
    local persistence=$1
    local qrels=$2
    local run=$3
    local scale=$(echo "scale=2; 1 / $MAXJ" | bc)
    printf -v suffix "rbp%.2f\n" $persistence
    $RBPEVAL -HWTq -f $scale -p $persistence $qrels $run \
        | awk '{print $4, $8}' \
        | sort -k1n > ${run}.${suffix}
}

if [ $# -lt 4 ]; then
    usage
    exit 1
fi

METRIC=$1; shift
case "$METRIC" in
    ndcg)
        EVALFUNC=eval_ndcg
        ;;
    err)
        EVALFUNC=eval_err
        ;;
    map)
        EVALFUNC=eval_map
        ;;
    rbp)
        EVALFUNC=eval_rbp
        ;;
    *)
        err "unknown metric $1"
        ;;
esac

cutoff_arg=$1; shift
qrels_arg=$1; shift
if [ -f $qrels_arg ]; then
    if [ "$METRIC" = "err" -o "$METRIC" = "rbp" ]; then
        # ERR requires the maximum judgment to be specified, RBP requires the
        # maximum judgment for graded evaluation.
        MAXJ=$(awk '{print $4}' $qrels_arg | sort -nu | tail -1)
    fi
fi

for i in $@; do
    $EVALFUNC $cutoff_arg $qrels_arg $i
done
