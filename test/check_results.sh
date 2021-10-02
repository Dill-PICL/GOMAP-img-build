cut -f 3,5 GOMAP-0.3_GOMAP-input/gaf/e.agg_data/0.3_GOMAP-input.aggregate.gaf | sort > results/new.txt
cut -f 3,5 0.3_GOMAP-input.aggregate.gaf  | sort > results/old.txt
diff results/new.txt results/old.txt
