#!/bin/bash

fileOfPid=$1

pidToKill=`cat /tmp/macWatch.$fileOfPid`

kill $pidToKill
