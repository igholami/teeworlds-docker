#!/bin/bash

if [ -z "$1" ]; then
    echo "Game type is required"
    exit 1
fi

game=$1
if [ "$game" == "ctf" ]; then
  ./teeworlds/teeworlds_srv -f teeworlds/ctf.cfg
elif [ "$game" == "ddnet" ]; then
  ./ddnet/ddnet_srv -f ddnet/ddnet.cfg
elif [ "$game" == "fng2" ]; then
  ./fng2/fng2_srv -f fng2/fng2.cfg
elif [ "$game" == "zcatch" ]; then
  ./zcatch/zcatch_srv -f zcatch/zcatch.cfg
else
  echo "Invalid game type"
  exit 1
fi

