#!/bin/bash

set -u
set -e
FAIL=0
if [ $# -eq 2 ]
then
    nodes=$1
    command="$2"
else
    nodes=`cat ./nodes`
    command=$1
fi
echo $command" for nodes:"$nodes 
for node in $nodes
do
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -t ubuntu@$node ${command/localhost/$node} &
done
echo $command done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
echo "$command finished." 
else
echo "Fail! ($FAIL)"
fi
