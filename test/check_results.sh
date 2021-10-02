cut -f 3,5 test/GOMAP-0.3_GOMAP-input/gaf/e.agg_data/0.3_GOMAP-input.aggregate.gaf | sort > test/results/new.txt
cut -f 3,5 test/results/0.3_GOMAP-input.aggregate.gaf  | sort > test/results/old.txt
num_lines=`diff test/results/new.txt test/results/old.txt | wc -l`

if [ $num_lines -gt 0 ]
then
	echo "test failed"
	exit 1
fi
