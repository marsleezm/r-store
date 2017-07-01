#!/bin/bash

Period=5
Duration=3200000
ClientInt=$((Period*1000))
OrgStatCnt=$((Duration / Period))
OrgStatCnt=$((OrgStatCnt / 1000))
UpCnt=10
CPUTH=65
DownCnt=20
LowCPUTH=65
StatCnt=$((OrgStatCnt+10))

sleep 1 
#echo $ClientInt
#echo $StatCnt
InitT=50
S1=$((InitT+60*8-40))
S2=$((InitT+60*10-30))
S3=$((InitT+60*14-15))
S4=$((InitT+60*16-15))
S5=$((InitT+60*17-30))
S6=$((InitT+60*24-15))
S7=$((InitT+60*36-15))
S8=$((InitT+60*38-15))
S9=$((InitT+60*42-30))
S10=$((InitT+60*44-30))
S11=$((InitT+60*46-30))
S12=$((InitT+60*52-30))

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

#sleep 30 && 
#./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 2 $Folder "plan2_ycsb.json" &&  sleep 30 &&
#./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 3 $Folder "plan3_ycsb.json" &&  sleep 30 &&
#./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 4 $Folder "plan4_ycsb.json" &&  sleep 30 &&
#./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 5 $Folder "plan5_ycsb.json" &&  
#./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 6 $Folder "plan6_ycsb.json" && sleep 30 &&
#./liscripts/monitor_and_scale.sh $CPUTH $CPUTHCnt $Period 5 $Folder "plan5_ycsb.json" &&  
#./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 6 $Folder "plan6_ycsb.json" && 
#./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 5 $Folder "plan7_ycsb.json" && 
#./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 4 $Folder "plan8_ycsb.json" && 
#./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 3 $Folder "plan9_ycsb.json" &
echo Plan1 will sleep $S1 && sleep $S1 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan2_het.json &
echo Plan2 will sleep $S2 && sleep $S2 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan3_het.json &
echo Plan3 will sleep $S3 && sleep $S3 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan4_het.json &
echo Plan4 will sleep $S4 && sleep $S4 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan5_het.json &
echo Plan5 will sleep $S5 && sleep $S5 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan6_het.json &
echo Plan6 will sleep $S6 && sleep $S6 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan7_het.json &
echo Plan7 will sleep $S7 && sleep $S7 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan8_het.json &
echo Plan8 will sleep $S8 && sleep $S8 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan9_het.json &
echo Plan9 will sleep $S9 && sleep $S9 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan10_het.json &
echo Plan10 will sleep $S10 && sleep $S10 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan11_het.json &
echo Plan11 will sleep $S11 && sleep $S11 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan12_het.json &
echo Plan12 will sleep $S12 && sleep $S12 && ant elastic-controller -Dproject=ycsb -DtWindow=15 -DnumPart=10  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=next_round.json -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=2 -DhighCPU=160 -DlowCPU=110 -DchangeParts=plan13_het.json &


#ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=16 -Dclient.blocking_concurrent=300 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true
ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=5 -Dclient.hosts="172.31.0.17;172.31.0.18;172.31.0.3;172.31.0.4;172.31.0.5" -Dclient.threads_per_host=8 -Dclient.blocking=false -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true

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
