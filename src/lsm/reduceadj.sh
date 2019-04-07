#!/bin/bash

for i in graph-*.txt; do
	cat $i | sed 's/.0000000e+00//g' > tmp.txt;
	mv tmp.txt $i;
done;

