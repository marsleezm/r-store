#!/bin/bash


FirstNode=`head -1 ./nodes`
pkill -f ant
./liscripts/parallel_command.sh "`cat ./nodes`" "pkill -f java"

plan=$1
Date=`(date +'%Y%m%d-%H%M%S')`
Folder="results/$Date"
mkdir $Folder
./liscripts/parallel_command.sh "`cat ./nodes`" 'cd r-store && rm output* && rm reconfig_output'
./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && mv txnrates.txt  txnrate.txt"


ssh ubuntu@$FirstNode "cd r-store && ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnoshutdown=true -Dnoexecute=true -Dsite.txn_restart_limit_sysproc=100 -Dsite.jvm_asserts=false -Dsite.reconfig_live=true | tee load_log" 1>$Folder/load_output 2>&1 &
res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
while [ "$res" == "" ]
do 
    echo "Wait for H-Store to finish loading"
    sleep 5 
    res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
done
echo H-Store finished loading

sleep 120 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=4 -DhighCPU=160 -DlowCPU=110 -DchangeParts="+9;+10;+11" | tee $Folder/planner.out &

ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=1200 -Dclient.duration=500000 -Dclient.interval=5000 -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=4 -Dclient.blocking_concurrent=100 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true

# Calculate when reconfig ended
scp ubuntu@$FirstNode:~/r-store/reconfig_output $Folder
F=$Folder/reconfig_output
ReconfigEnd=`tail -2 $F | head -1 | awk -F ':' '{print $2}'`
ReconfigDuration=`tail -1 $F | awk -F ': ' '{print $2}'`
ReconfigStart=$((ReconfigEnd-ReconfigDuration))
echo $ReconfigStart >> $F
