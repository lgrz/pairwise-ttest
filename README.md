# Pairwise t-test

Scripts to perform pairwise t-test on TREC run files.

### Requirements

* R
    * [reshape2][reshape2]
* [gdeval.pl][gdeval] - note this is a fork that adds options `-k <cutoff>` and
  `-j <max judgment>` to the original [trec-web/trec-web-2013][trecweb]
* [trec\_eval][treceval]
* [rbp\_eval][rbpeval]

[reshape2]: https://cran.r-project.org/web/packages/reshape2/index.html
[gdeval]: https://github.com/lgrz/trec-web-2013
[treceval]: https://trec.nist.gov/trec_eval
[rbpeval]: https://people.eng.unimelb.edu.au/ammoffat/rbp_eval-0.2.tar.gz
[trecweb]: https://github.com/trec-web/trec-web-2013

### Usage

There are two bash scripts to run. First run `pairwise-eval.sh` to evaluate the
TREC run files. Then run `pairwise-ttest.sh` to compute statistical
significance.

The bash scripts assume that `rbp_eval`, `gdeval.pl` and `trec_eval` can be found in your
`PATH` environment.

To compute a pairwise t-test of all run files in the `runs` directory for
NDCG@10 using `foo.qrels` (which contains the relevance judgments), run
the following:

```
./pairwise-eval.sh ndcg 10 foo.qrels runs/*.run
./pairwise-ttest.sh runs/*.run.ndcg10 > result.txt
cat result.txt
```

The `pairwise-eval.sh` script can compute ERR, NDCG, RBP and MAP. `gdeval.pl`
is used for ERR and NDCG, `rbp_eval` for RBP, and `trec_eval` is used for MAP.
