CC?=cc
CFLAGS?=-Wall -Wextra -pedantic -O3

NUM_RECS := 1000 10000 100000 1000000
NUM_POINTS := 1000 10000 100000 1000000 10000000
OVERLAP_PCT := 0.0 0.25 0.5 

conversion: pbbs2fut fut2pbbs

%: %.c
	$(CC) -o $@ $(CFLAGS) $^

mk_datasets: mk_datasets.fut
	futhark cuda mk_datasets.fut

datasets_pbbs: conversion
	randPoints -d 2 -n 1000000 1M.pbbs
	pbbs2fut < 1M.pbbs > data/1M.in

datasets_synthetic: mk_datasets 
	mkdir -p ../data
	$(foreach n,$(NUM_RECS), \
		$(foreach m,$(NUM_POINTS), \
			$(foreach p,$(OVERLAP_PCT), \
					echo "$(n) $(m) $(p)" | ./mk_datasets > ../data/$(n)_$(m)_$(p).in; \
			) \
		) \
	)

datasets: datasets_pbbs datasets_synthetic

benchmark: 
	mkdir -p ../results
	futhark bench --backend=cuda --json=results/performant.json rangeQuery2dPerformant.fut > ../results/performant.out
	futhark bench --backend=cuda --json=results/naive.json rangeQuery2dNaive.fut > ../results/naive.out

futhark_comment:
	@for n in $(NUM_RECS); do \
		for m in $(NUM_POINTS); do \
			for p in $(OVERLAP_PCT); do \
				echo "-- notest compiled input @ ../data/$${n}_$${m}_$${p}.in"; \
			done \
		done \
	done


