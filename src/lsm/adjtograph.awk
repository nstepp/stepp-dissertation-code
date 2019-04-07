BEGIN {

	print "digraph adjGraph {";

}



{
	for(i=1;i<=NF;i++) {
		src = "N" NR;
		dst = "N" i;

		if( $i == "1.0000000e+00" ) {
			print src " -> " dst;
		} else if( $i == "-1.0000000e+00" ) {
			print src " -> " dst " [style=dashed]";
		}
	}
}


END {

	print "}";

}

