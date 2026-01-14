CC?=cc
CFLAGS?=-Wall -Wextra -pedantic -O3

NUM_RECS := 100 1000 10000 100000 1000000 10000000
OVERLAP_PCT := 0.0 0.2 0.4 0.6 0.8 1.0

all: pbbs2fut fut2pbbs

%: %.c
	$(CC) -o $@ $(CFLAGS) $^

datasets:
	$(foreach n,$(NUM_RECS), \
		$(foreach p,$(OVERLAP_PCT), \
			echo "$(n) $(n) $(p)" | ./mk_datasets > data/dataset_$(n)_$(p).in; \
		) \
	)
