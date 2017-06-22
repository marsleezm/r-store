#!/bin/bash


FirstNode=`head -1 ./nodes`
#### Cleanup
pkill -f ant
rm hotTuplesPID*
rm siteLoadPID*
./liscripts/parallel_command.sh "`cat ./nodes`" "pkill -f java" &
for node in `cat ./nodes` 
do
    ssh ubuntu@$node 'cd r-store && rm -f output* && rm -f reconfig_output' &
done
./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && mv txnrates.txt  txnrate.txt" &
wait

### Make folder
plan=$1
Date=`(date +'%Y%m%d-%H%M%S')`
Folder="results/$Date"
mkdir $Folder

### Load the data store
ssh ubuntu@$FirstNode "cd r-store && ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnoshutdown=true -Dnoexecute=true -Dsite.txn_restart_limit_sysproc=100 -Dsite.jvm_asserts=false -Dsite.reconfig_live=true | tee load_log" 1>$Folder/load_output 2>&1 &
res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
while [ "$res" == "" ]
do 
    echo "Wait for H-Store to finish loading"
    sleep 5 
    res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
done
echo H-Store finished loading

ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=1000 -Dclient.duration=60000 -Dclient.interval=5000 -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=8 -Dclient.blocking_concurrent=100 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true

# Calculate when reconfig ended
scp ubuntu@$FirstNode:~/r-store/reconfig_output $Folder
F=$Folder/reconfig_output
ReconfigStart=`head -1 $F | awk -F ':' '{print $2}'`
ReconfigEnd=`tail -2 $F | head -1 | awk -F ':' '{print $2}'`
echo $((ReconfigEnd-ReconfigStart)) >> $F
echo $ReconfigStart >> $F
echo $ReconfigEnd >> $F
