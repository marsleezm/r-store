#!/bin/bash

rm bench_out.txt
./liscripts/uniform_het1.sh  ./plan1_het.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		rm bench_out.txt
		pkill -f proactive 
		pkill -f uniform
		./liscripts/uniform_het1.sh ./plan1_het.json &
		pid=$!
	fi
	sleep 10
done
sleep 3


rm bench_out.txt
./liscripts/start_new_plan1.sh hosts_het.txt ./plan6_het.json
./liscripts/uniform_het2.sh  ./plan6_het.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		rm bench_out.txt
		pkill -f proactive 
		pkill -f uniform
		./liscripts/start_new_plan1.sh hosts_het.txt ./plan6_het.json
		./liscripts/uniform_het2.sh ./plan6_het.json &
		pid=$!
	fi
	sleep 10
done
sleep 3



exit


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
exit

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
