#!/bin/bash

total_cpu=0
NL=$2
NL1=$((NL+1))
for f in `ls $1/*sarout`
do
	numcpu=`head -1 $f | awk -F '(' '{print $3}' | awk '{print $1}'`
	total_cpu=$((total_cpu+numcpu))
	tail -${NL1} $f > tmp
	head -${NL} tmp > tmp2
	awk -v var="$numcpu" -F ' ' '{print (100 - $9)*var}' tmp2 > $f-tmpres
done

paste $1/*-tmpres | awk -v var="$total_cpu" 'sum=0;{for (i=1;i<=NF;i++) sum+=$i}{print (sum/var)}' > $1/cpu_usage
