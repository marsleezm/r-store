#!/bin/bash

Period=5
Duration=1200000
ClientInt=$((Period*1000))
OrgStatCnt=$((Duration / Period))
OrgStatCnt=$((OrgStatCnt / 1000))
CPUTHCnt=10
CPUTH=40
StatCnt=$((OrgStatCnt+10))
echo $ClientInt
echo $StatCnt

FirstNode=`head -1 ./nodes`
#### Cleanup
pkill -f ant
pkill -f sar
pkill -f monitor
rm hotTuplesPID*
rm siteLoadPID*
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
HostFile="${plan/json/txt}"
HostFile="${HostFile/plan/hosts}"
echo $HostFile
NumHosts=`cat $HostFile | wc -l`
OrgHostNum=$((NumHosts-1))


### Make folder
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

./liscripts/monitor_cpu.sh $Folder $Period 

#sleep 30 && ant elastic-controller -Dproject=ycsb -DtWindow=20 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=$NumHosts -DhighCPU=160 -DlowCPU=110 -DchangeParts=";" | tee $Folder/planner1.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json ./r-store && sleep 210 && ./liscripts/monitor_and_scale.sh $CPUTH $CPUTHCnt $Period $OrgHostNum $Folder & 
#sleep 30 && ant elastic-controller -Dproject=ycsb -DtWindow=20 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=$NumHosts -DhighCPU=160 -DlowCPU=110 -DchangeParts=";" | tee $Folder/planner1.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json ./r-store && sleep 210 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=3 -DhighCPU=160 -DlowCPU=110 -DchangeParts="+9;+10;+11" | tee $Folder/controller_scale.out & 

sleep 30 && ant elastic-controller -Dproject=ycsb -DtWindow=20 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=$NumHosts -DhighCPU=160 -DlowCPU=110 -DchangeParts=";" | tee $Folder/planner1.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json ./r-store & 
sleep 460 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=3 -DhighCPU=160 -DlowCPU=110 -DchangeParts="+9;+10;+11" | tee $Folder/controller_scale.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json ./r-store & 
sleep 1000 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=3 -DhighCPU=160 -DlowCPU=110 -DchangeParts="-9;-10;-11" | tee $Folder/controller_scale_down.out & 

#sleep 90 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=3 -DhighCPU=160 -DlowCPU=110 -DchangeParts="+9;+10;+11" | tee $Folder/controller_scale.out && cp plan_out.json next_round.json && ./liscripts/copy_to_all.sh "`cat ./nodes`" ./next_round.json ./r-store & 
#sleep 450 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=3 -DhighCPU=160 -DlowCPU=110 -DchangeParts="-9;-10;-11" | tee $Folder/controller_scale_down.out & 


ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=100 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=8 -Dclient.blocking_concurrent=100 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true

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
