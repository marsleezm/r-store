#!/bin/bash

rm bench_out.txt
./liscripts/uniform_het.sh ./plan1_het.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		rm bench_out.txt
		./liscripts/uniform_het.sh ./plan1_het.json &
		pid=$!
	#else
		#res=`tail -200 bench_out.txt | grep "Latencies 99" | awk -F 'Latencies 99: ' '{print $2}' | awk -F '(' '{print $1}'`
		#ff=($res)
		#if [ ${#ff[@]} -gt 2 ] && [ ${ff[0]} == ${ff[1]} ] && [ ${ff[1]} == ${ff[2]} ]
		#then
	#		echo "Aborted!!!!! Restart"
	#		pkill -f reactive		
#			pkill -f uniform
#			pkill -f plan
#			pkill -f sar
#			pkill -f ant
#			rm bench_out.txt
#			./liscripts/uniform_het.sh ./plan1_het.json &
#			pid=$!
#		fi
	fi
	sleep 10
done
exit

if [ 1 == 2 ]
then
rm bench_out.txt
./liscripts/reactive.sh ./plan1_ycsb.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		rm bench_out.txt
		./liscripts/reactive.sh ./plan1_ycsb.json &
		pid=$!
	else
		res=`tail -80 bench_out.txt | grep "ms avg latency" | awk -F 'with ' '{print $2}' | awk -F ' ' '{print $1}'`
		ff=($res)
		if [ ${#ff[@]} -gt 1 ] && [ ${ff[0]} == ${ff[-1]} ] && [ ${ff[0]} == ${ff[1]} ]
		then
			echo "Aborted!!!!! Restart"
			pkill -f reactive		
			pkill -f uniform
			pkill -f plan
			pkill -f sar
			pkill -f ant
			rm bench_out.txt
			./liscripts/reactive.sh ./plan1_ycsb.json &
			pid=$!
		fi
	fi
	sleep 10
done
sleep 3
fi

rm bench_out.txt
./liscripts/proactive.sh ./plan1_ycsb.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		rm bench_out.txt
		./liscripts/proactive.sh ./plan1_ycsb.json &
		pid=$!
	else
		res=`tail -80 bench_out.txt | grep "ms avg latency" | awk -F 'with ' '{print $2}' | awk -F ' ' '{print $1}'`
		ff=($res)
		if [ ${#ff[@]} -gt 1 ] && [ ${ff[0]} == ${ff[-1]} ] && [ ${ff[0]} == ${ff[1]} ]
		then
			echo "Aborted!!!!! Restart"
			pkill -f reactive		
			pkill -f uniform
			pkill -f plan
			pkill -f sar
			pkill -f ant
			rm bench_out.txt
			./liscripts/proactive.sh ./plan1_ycsb.json &
			pid=$!
		fi
	fi
	sleep 10
done

while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		pkill -f reactive		
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		rm bench_out.txt
		./liscripts/proactive.sh ./plan1_ycsb.json &
		pid=$!
	else
		res=`tail -80 bench_out.txt | grep "ms avg latency" | awk -F 'with ' '{print $2}' | awk -F ' ' '{print $1}'`
		ff=($res)
		if [ ${#ff[@]} -gt 1 ] && [ ${ff[0]} == ${ff[-1]} ] && [ ${ff[0]} == ${ff[1]} ]
		then
			echo "Aborted!!!!! Restart"
			pkill -f reactive		
			pkill -f uniform
			pkill -f plan
			pkill -f sar
			pkill -f ant
			rm bench_out.txt
			./liscripts/proactive.sh ./plan1_ycsb.json &
			pid=$!
		fi
	fi
	sleep 10
done

exit

#rm bench_out.txt
#./liscripts/uniform_het.sh  ./plan1_het.json &
#pid=$!
#while kill -0 "$pid" >/dev/null 2>&1; do
#	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
#	then
#		echo "Aborted!!!!! Restart"
#		rm bench_out.txt
#		pkill -f uniform
#		pkill -f plan
#		pkill -f sar
#		pkill -f ant
#		./liscripts/uniform_het.sh ./plan1_het.json &
#		pid=$!
#	fi
#	sleep 10
#done
#sleep 3
#exit

rm bench_out.txt
./liscripts/start_new_plan.sh hosts_het.txt ./plan1_het.json
./liscripts/uniform_het1.sh  ./plan1_het.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		rm bench_out.txt
		pkill -f proactive 
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		./liscripts/uniform_het1.sh ./plan1_het.json &
		pid=$!
	fi
	sleep 10
done
sleep 3

rm bench_out.txt
./liscripts/start_new_plan.sh hosts_het.txt ./plan6_het.json
./liscripts/uniform_het2.sh  ./plan6_het.json &
pid=$!
while kill -0 "$pid" >/dev/null 2>&1; do
	if tail -100 bench_out.txt | grep -q "with NaN ms avg latency" 
	then
		echo "Aborted!!!!! Restart"
		rm bench_out.txt
		pkill -f proactive 
		pkill -f uniform
		pkill -f plan
		pkill -f sar
		pkill -f ant
		#./liscripts/start_new_plan.sh hosts_het.txt ./plan6_het.json
		./liscripts/uniform_het2.sh ./plan6_het.json &
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
