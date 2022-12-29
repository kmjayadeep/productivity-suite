#!/bin/sh

set -e

while true;
do
  echo "backing up";
  restic --verbose backup /data
  restic --verbose backup /config
  echo "backup successful"
  echo "current snapshots:"
  restic snapshots
  sleep 3600
done
