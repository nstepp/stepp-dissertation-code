#!/bin/bash

for i in `seq 1 16`; do

	edf2asc -e -y TRIAL$i.EDF
	if [ -f TRIAL$i.asc ]; then
		mv TRIAL$i.asc TRIAL$i-events.asc
		grep 'PRES [0-9]* START'  TRIAL$i-events.asc| awk '{print $2;}' > "start$i.txt"
	fi

	edf2asc -s -miss NaN -y TRIAL$i.EDF
	if [ -f TRIAL$i.asc ]; then
		cat TRIAL$i.asc | awk '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $6 "\t" $7 "\t" $8; }' > gaze$i.txt
	fi
done

