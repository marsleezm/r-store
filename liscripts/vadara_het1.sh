#!/bin/bash

Period=5
Duration=1100000
ClientInt=$((Period*1000))
OrgStatCnt=$((Duration / Period))
OrgStatCnt=$((OrgStatCnt / 1000))
StatCnt=$((OrgStatCnt+10))

sleep 1 
#echo $ClientInt
#echo $StatCnt
InitT=50
A1=$((InitT+60*1-30))
A2=$((InitT+60*3-40))
A3=$((InitT+60*5-30))
A4=$((InitT+60*7-30))
A5=$((InitT+60*9-30))
A6=$((InitT+60*15-30))



FirstNode=`head -1 ./nodes`
#### Cleanup
pkill -f ant
pkill -f sar
pkill -f monitor
pkill -f r-store
pkill -f sleep
./liscripts/parallel_command.sh  "`cat ./nodes`" "sudo /etc/init.d/ntp stop && sudo ntpdate ntp.ubuntu.com" & 
./liscripts/parallel_command.sh  "`cat ./clients`" "sudo /etc/init.d/ntp stop && sudo ntpdate ntp.ubuntu.com" &
#rm hotTuplesPID*
#rm siteLoadPID*
./liscripts/parallel_command.sh "`cat ./nodes`" "pkill -f java" &
./liscripts/parallel_command.sh "`cat ./nodes`" "pkill -f sar" &
./liscripts/copy_to_all.sh "`cat ./clients`" ./txnrates.txt ./r-store &
for node in `cat ./nodes` 
do
    ssh ubuntu@$node 'cd r-store && rm -f output* && rm -f reconfig_output' &
done
#./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && mv txnrates.txt  txnrate.txt" &
wait

plan=$1

### Make folder
Date=`(date +'%Y%m%d-%H%M%S')`
Folder="results/$Date"
mkdir $Folder

### Load the data store
ssh ubuntu@$FirstNode "cd r-store && ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnoshutdown=true -Dnoexecute=true -Dsite.txn_restart_limit_sysproc=20000 -Dsite.jvm_asserts=false -Dsite.reconfig_live=true -Dsite.reconfig_async=true -Dsite.reconfig_async_pull=true | tee load_log" 1>$Folder/load_output 2>&1 &
res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
while [ "$res" == "" ]
do 
    echo "Wait for H-Store to finish loading"
    sleep 5 
    res=`grep "H-Store cluster remaining online until killed" $Folder/load_output`
done
echo H-Store finished loading

./liscripts/monitor_cpu.sh $Folder $Period 

echo Plan1 will sleep $A1 && sleep $A1 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan2_vad.json  &
echo Plan2 will sleep $A2 && sleep $A2 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan3_vad.json  &
echo Plan3 will sleep $A3 && sleep $A3 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan4_vad.json  &
echo Plan4 will sleep $A4 && sleep $A4 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan5_vad.json  &
echo Plan5 will sleep $A5 && sleep $A5 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan6_vad.json  &
echo Plan6 will sleep $A6 && sleep $A6 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan7_vad.json  &


#ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=16 -Dclient.blocking_concurrent=300 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true
ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=5 -Dclient.hosts="172.31.0.2;172.31.0.6;172.31.0.7;172.31.0.8;172.31.0.9" -Dclient.threads_per_host=8 -Dclient.blocking=false -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true | tee bench_out.txt
pkill -f sar
 
# Gather cpu usage
./liscripts/process_cpu.sh $Folder $OrgStatCnt 

# Calculate when reconfig ended
scp ubuntu@$FirstNode:~/r-store/reconfig_output $Folder
F=$Folder/reconfig_output
#ReconfigStart=`head -1 $F | awk -F ':' '{print $2}'`
#ReconfigEnd=`tail -2 $F | head -1 | awk -F ':' '{print $2}'`
#echo $((ReconfigEnd-ReconfigStart)) >> $F
#echo $ReconfigStart >> $F
#echo $ReconfigEnd >> $F
