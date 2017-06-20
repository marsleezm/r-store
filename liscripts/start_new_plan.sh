#!/bin/bash

HostFile=$1
PlanFile=$2

./liscripts/parallel_command.sh "`cat ./nodes`" "pkill -f java" &

./liscripts/copy_to_all.sh "`cat ./clients`" $HostFile ~/r-store &
./liscripts/copy_to_all.sh "`cat ./nodes`" $HostFile ~/r-store &
./liscripts/copy_to_all.sh "`cat ./clients`" $PlanFile ~/r-store &
./liscripts/copy_to_all.sh "`cat ./nodes`" $PlanFile ~/r-store &
wait

./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && ant hstore-prepare -Dproject=ycsb -Dhosts=$1" &
./liscripts/parallel_command.sh "`cat ./nodes`" "cd r-store && ant hstore-prepare -Dproject=ycsb -Dhosts=$1" &
wait
