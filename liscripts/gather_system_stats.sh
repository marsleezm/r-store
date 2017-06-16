#!/bin/bash

set -u
set -e
FAIL=0
for node in `cat ./nodes` 
do
    scp $node:~/r-store/"hotTuplesPID_*" . &
    scp $node:~/r-store/"siteLoadPID_*" . &
done

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
echo "Finished." 
else
echo "Fail! ($FAIL)"
fi
