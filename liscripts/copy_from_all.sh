#!/bin/bash

FAIL=0
echo $command" for nodes:"$nodes 
if [ $# -eq 3 ]
then
    nodes=`cat ./nodes`
    file=$1
    path=$2
    folder=$3
else
    nodes=$1
    file=$2
    path=$3
    folder=$4
fi
for node in $nodes
do
    SafeFileName=$node-$file
    scp ubuntu@$node:$path/$file $folder/$SafeFileName &
    #mv $folder/$FileName $folder/$SafeFileName
done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done
