#!/bin/bash

plan=$1
./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && mv txnrates.txt  txnrate.txt"

sleep 90 && ant elastic-controller -Dproject=ycsb -DtWindow=12 -DnumPart=12  -DplannerID=1 -Dprovisioning=0 -DtimeLimit=5000 -Dglobal.hasher_plan=$plan -Dmonitoring=0 -DsitesPerHost=1 -DpartPerSite=4 -DhighCPU=160 -DlowCPU=110 -DchangeParts="+9;+10;+11" | tee test_planner.out &

ant hstore-benchmark -Dproject=ycsb -Dglobal.hasher_plan=$plan -Dglobal.hasher_class=edu.brown.hashing.TwoTieredRangeHasher -Dnostart=true -Dnoloader=true -Dnoshutdown=true -Dclient.txnrate=1000 -Dclient.duration=300000 -Dclient.interval=5000 -Dclient.count=2 -Dclient.hosts="172.31.0.17;172.31.0.18" -Dclient.threads_per_host=4 -Dclient.blocking_concurrent=100 -Dclient.output_results_csv=test_benchmark.csv -Dclient.output_interval=true
