#!/bin/sh

while true;
do
  echo "backing up";
  restic snapshots
  sleep 60
done
