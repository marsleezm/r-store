#!/bin/bash

threshold=$1
min_count=$2
monitor_period=$3
num_nodes=$4
folder=$5
num_all_nodes=$((num_nodes + 1))


cnt=0
total_cpu=0
# Loop forever, unless scaling is triggered or is killed
while [ 1 -eq 1 ]
do
    total_usage=0
    total_cpu=0
    node_cnt=0
    for f in `ls $folder/*sarout*`
    do
	    numcpu=`head -1 $f | awk -F '(' '{print $3}' | awk '{print $1}'`
            total_cpu=`bc <<< "$total_cpu + $numcpu" `
    	    idle=`tail -1 $f | awk -F ' ' '{print $9}'`
	    usage=`bc <<< "100-$idle"`
	    c_usage=$(bc <<< "$usage * $numcpu")
	    echo  "Usage is "$c_usage
	    total_usage=$(bc <<< "$total_usage+$c_usage")
		node_cnt=$((node_cnt+1))
    done
    th_usage=$((threshold * total_cpu))
    echo "Total is " $total_usage , th usage is $th_usage
    larger=`echo $total_usage'<'$th_usage | bc -l`
    if [ $larger -eq 1 ]
    then
	echo "Usage thresdhold hit, count is "$cnt
	cnt=$((cnt+1))
    else
	echo "Usage thresdhold not hit, count is reset"
	cnt=0
    fi
 
    if [ $cnt -ge $min_count ]
    then
	echo "Decide to scale!" 
	ant elastic-controller -Dproject=ycsb -DtWindow=2 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=$((12 / num_all_nodes)) -DhighCPU=160 -DlowCPU=110 -DchangeParts="-9;-10;-11" | tee $folder/controller_scale_down.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json
        break
    fi
    sleep $monitor_period
done
