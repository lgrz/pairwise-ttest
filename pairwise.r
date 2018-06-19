library(reshape2)

args <- commandArgs(T)
if (!length(args)) {
    stop("need file")
}
t <- read.table(args[1], header=T)
s <- melt(t, id.vars='qid', value.name='score')
pairwise.t.test(s$score, factor(s$variable), p.adjust='bon', paired=T)
