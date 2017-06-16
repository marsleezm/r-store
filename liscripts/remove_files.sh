#!/bin/bash


nodes=`cat ./nodes`
for node in $nodes
do
    ssh ubuntu@$node 'cd ~/r-store/ && rm hotTuplesPID* && rm siteLoadPID*' &
done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done
