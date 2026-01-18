# rangeQuery2d implementation in Futhark

The following is a rangeQuery2d implementation in Futhark, which makes use of
BVH trees to find points inside rectangles.

## Synthetic data generation

To create the synthetic data used, one has to first create the mk\_datasets
futhark, which can be done with '''make mk_datasets''' to generate one made for
cuda backend. If wished to be run for another backend then this must be done
manually. Afterwards, one can run datasets_synthetic to generate the synthetic
data.

The make '''futhark\_comment''' target creates a comment which can be used in
the futhark main file to correctly target the new generated files.

## PBBS data generation

This assumes that the randPoints binary already has been compiled and placed
within the src folder. Then datasets_pbbs can be run to create some random
pbbs_data. 

## Specifying sizes

The Makefile allows you to specify different number of recs, points and overlap
according to the accompanying report. Make sure to update this both before you
run the futhark_comment and the data generation.
