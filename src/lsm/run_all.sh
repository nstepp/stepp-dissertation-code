#/bin/bash

for nodeset in 50 500; do

	cd ${nodeset}nodes

	for graphset in 1 2 3; do

		
		cd graphset$graphset


		for edge in `seq 1 10`; do
			for neg in `seq 1 10`; do

				echo $nodeset	$graphset	$edge	$neg

				time ../../lsm -t 200 -d 0.05 -n $(( nodeset / 50  )) -i graph-$edge-$neg.txt -o sim-$edge-$neg

			done
		done


		cd ..

	done

	cd ..
done




