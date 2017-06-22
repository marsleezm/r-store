#!/bin/bash

folder=$1
period=$2
nodes=`cat ./nodes`
for node in $nodes
do 
	ssh ubuntu@$node  "sar $period" > $folder/$node-sarout &
done
