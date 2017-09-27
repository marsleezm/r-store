#!/bin/bash

Period=5
Duration=1400000
ClientInt=$((Period*1000))
OrgStatCnt=$((Duration / Period))
OrgStatCnt=$((OrgStatCnt / 1000))
StatCnt=$((OrgStatCnt+10))

sleep 1 
#echo $ClientInt
#echo $StatCnt
InitT=50
Red=1000
A7=$((InitT+60*23-30-Red))
A8=$((InitT+60*27-30-Red))


R1=$((InitT+60*19-Red))
R2=$((InitT+60*21-Red))
R3=$((InitT+60*29-Red))
R4=$((InitT+60*31-Red))
R5=$((InitT+60*33-Red))
R6=$((InitT+60*35-Red))
R7=$((InitT+60*37-Red))

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

echo Plan6 will sleep $R1 && sleep $R1 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan8_vad.json  &
echo Plan6 will sleep $R2 && sleep $R2 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan9_vad.json  &
echo Plan7 will sleep $A7 && sleep $A7 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan10_vad.json  &
echo Plan7 will sleep $A8 && sleep $A8 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan11_vad.json  &
echo Plan8 will sleep $R3 && sleep $R3 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan12_vad.json  &
echo Plan8 will sleep $R4 && sleep $R4 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan13_vad.json  &
echo Plan8 will sleep $R5 && sleep $R5 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan14_vad.json  &
echo Plan8 will sleep $R6 && sleep $R6 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan15_vad.json  &
echo Plan8 will sleep $R7 && sleep $R7 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan16_vad.json  &


#ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=16 -Dclient.blocking_concurrent=300 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true
ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=5 -Dclient.hosts="172.31.0.2;172.31.0.3;172.31.0.4;172.31.0.5;172.31.0.6" -Dclient.threads_per_host=8 -Dclient.blocking=false -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true | tee bench_out.txt
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
