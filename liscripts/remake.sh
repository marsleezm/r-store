#!/bin/bash

./liscripts/parallel_command.sh "cd r-store && git stash && git pull && ant compile"
#ant hstore-prepare -Dproject=ycsb -Dhosts=local_ycsb.txt

