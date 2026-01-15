CC?=cc
CFLAGS?=-Wall -Wextra -pedantic -O3

NUM_RECS := 1000 10000 100000 1000000
NUM_POINTS := 1000 10000 100000 1000000 10000000
OVERLAP_PCT := 0.0 0.25 0.5 

all: pbbs2fut fut2pbbs

%: %.c
	$(CC) -o $@ $(CFLAGS) $^

datasets:
	mkdir -p data
	$(foreach n,$(NUM_RECS), \
		$(foreach m,$(NUM_POINTS), \
			$(foreach p,$(OVERLAP_PCT), \
					echo "$(n) $(m) $(p)" | ./mk_datasets > data/$(n)_$(m)_$(p).in; \
			) \
		) \
	)

benchmark: 
	mkdir -p results
	futhark bench --backend=cuda --json=results/performant.json rangeQuery2dPerformant.fut > results/performant.out
	futhark bench --backend=cuda --json=results/naive.json rangeQuery2dNaive.fut > results/naive.out

futhark_comment:
	@for n in $(NUM_RECS); do \
		for m in $(NUM_POINTS); do \
			for p in $(OVERLAP_PCT); do \
				echo "-- notest compiled input @ data/$${n}_$${m}_$${p}.in"; \
			done \
		done \
	done


