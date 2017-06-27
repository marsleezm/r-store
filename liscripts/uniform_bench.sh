#!/bin/bash

Period=5
Duration=3000000
ClientInt=$((Period*1000))
OrgStatCnt=$((Duration / Period))
OrgStatCnt=$((OrgStatCnt / 1000))
UpCnt=10
CPUTH=65
DownCnt=20
LowCPUTH=65
StatCnt=$((OrgStatCnt+10))
echo $ClientInt
echo $StatCnt

FirstNode=`head -1 ./nodes`
#### Cleanup
./liscripts/parallel_command.sh  "`cat ./nodes`" "sudo /etc/init.d/ntp stop && sudo ntpdate ntp.ubuntu.com" & 
./liscripts/parallel_command.sh  "`cat ./clients`" "sudo /etc/init.d/ntp stop && sudo ntpdate ntp.ubuntu.com" &
pkill -f ant
pkill -f sar
pkill -f monitor
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
ssh ubuntu@$FirstNode "cd r-store && ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnoshutdown=true -Dnoexecute=true -Dsite.txn_restart_limit_sysproc=100 -Dsite.jvm_asserts=false -Dsite.reconfig_live=true -Dsite.reconfig_async=true -Dsite.reconfig_async_pull=true | tee load_log" 1>$Folder/load_output 2>&1 &
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
S1=$((5*5+180))
S2=$((5*100+180))
S3=$((5*126+180))
S4=$((5*200+180))
S5=$((5*274+120))
S6=$((5*440+180))
S7=$((5*462+120+30))
S8=$((5*475+120+30))
S9=$((5*510+120))
S10=$((5*560+120))
sleep $S1 && ./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 2 $Folder "plan2_ycsb.json" &
sleep $S2 && ./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 3 $Folder "plan3_ycsb.json" &
sleep $S3 && ./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 4 $Folder "plan4_ycsb.json" &
sleep $S4 && ./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 5 $Folder "plan5_ycsb.json" &  
sleep $S5 && ./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 6 $Folder "plan6_ycsb.json" &
sleep $S6 && ./liscripts/monitor_and_scale.sh $CPUTH $UpCnt $Period 5 $Folder "plan5_ycsb.json" &
sleep $S7 && ./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 6 $Folder "plan6_ycsb.json" & 
sleep $S8 && ./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 5 $Folder "plan7_ycsb.json" & 
sleep $S9 && ./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 4 $Folder "plan8_ycsb.json" & 
sleep $S10 && ./liscripts/monitor_and_scale_down.sh $CPUTH $DownCnt $Period 3 $Folder "plan9_ycsb.json" & 


#ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=16 -Dclient.blocking_concurrent=300 -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true
ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=50 -Dclient.duration=$Duration -Dclient.interval=$ClientInt -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=16 -Dclient.blocking=false -Dclient.output_results_csv=$Folder/benchmark.csv -Dclient.output_interval=true

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
