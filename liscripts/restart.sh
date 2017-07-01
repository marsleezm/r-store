#!/bin/bash

rm bench_out.txt
./liscripts/reactive.sh ./plan1_ycsb5.json &
pid=$!

while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		rm bench_out.txt
		./liscripts/reactive.sh ./plan1_ycsb5.json &
		pid=$!
	fi
	sleep 10
done
sleep 3

rm bench_out.txt
./liscripts/proactive.sh ./plan1_ycsb5.json &
pid=$!

while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		rm bench_out.txt
		./liscripts/proactive.sh ./plan1_ycsb5.json &
		pid=$!
	fi
	sleep 10
done
