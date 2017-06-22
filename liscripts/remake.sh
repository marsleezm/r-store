#!/bin/bash

./liscripts/parallel_command.sh "`cat ./clients`" "cd r-store && git stash save -u && git pull && ant compile" &
./liscripts/parallel_command.sh "`cat ./nodes`" "cd r-store && git stash save -u && git pull && ant compile"
#ant hstore-prepare -Dproject=ycsb -Dhosts=local_ycsb.txt

