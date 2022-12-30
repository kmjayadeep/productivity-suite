#!/bin/bash

# setup.sh: Setup productivity suite
# prereqs: bash, syncthing, jq, curl
# syncthing api token to be provided as SYNCTHING_API_TOKEN env variable

shopt -s direxpand
set -e

SCRIPT_DIR=$HOME/scripts
DATA_DIR=$HOME/.psuite
SYNCTHING_URL="http://localhost:8385"

while getopts ":s:d:e:h" opt; do
  case $opt in
    s) SCRIPT_DIR="$OPTARG"
    ;;
    d) DATA_DIR="$OPTARG"
    ;;
    e) SYNCTHING_URL="$OPTARG"
    ;;
    h)
      # Display the usage message
      echo "Usage: $0 -s SCRIPTS_DIR -d DATA_DIR -e SYNCTHING_ENDPOINT"
      exit 0
    ;;
    \?)
      # Display an error message if an invalid option is specified
      echo "Invalid option: -$OPTARG" >&2
      exit 1
    ;;
    :)
      # Display an error message if an option is missing an argument
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
    ;;
  esac
done

if [ ! -d "$SCRIPT_DIR" ]; then
  echo "Error: Directory does not exist: $SCRIPT_DIR"
  exit 1
fi

if [ ! -d "$DATA_DIR" ]; then
  mkdir "$DATA_DIR"
fi

mkdir -p "$DATA_DIR/notes"
mkdir -p "$DATA_DIR/todo"
mkdir -p "$DATA_DIR/mindmap"

REMOTE_ID=$(curl -s $SYNCTHING_URL/rest/system/status -H "X-API-KEY:$SYNCTHING_API_TOKEN" | jq -r '.myID')

if syncthing cli config devices | grep $REMOTE_ID &>/dev/null; then
  echo "Remote device was already added"
else
  syncthing cli config devices add --device-id $REMOTE_ID --name psuite-server --untrusted
  echo "Remote device added"
fi

LOCAL_SYNCTHING_ID=$(syncthing cli show system | jq -r '.myID')

curl -X POST -H "X-API-KEY: $SYNCTHING_API_TOKEN" -H "Content-Type: application/json" -d "{\"deviceID\":\"$LOCAL_SYNCTHING_ID\",\"name\":\"$(hostname)\"}" $SYNCTHING_URL/rest/config/devices

if syncthing cli config folders | grep psuite-notes &>/dev/null; then
  echo "Folders were already added"
else
  syncthing cli config folders add --path $DATA_DIR/notes --id psuite-notes --label psuite-notes
  syncthing cli config folders add --path $DATA_DIR/todo --id psuite-todo --label psuite-todo
  syncthing cli config folders add --path $DATA_DIR/mindmap --id psuite-mindmap --label psuite-mindmap
  echo "Folders added in syncthing"
fi

cp ./mm $SCRIPT_DIR
cp ./notes $SCRIPT_DIR

echo "
To complete the process,

1. Open syncthing on local and enable sharing the above folders with an encryption password
2. Open syncthing on remote and enable sharing for the folders to your local device with the name $(hostname)
3. Add the following to your environment variables through bashrc/zshrc or similar

export PSUITE_NOTES_DIR=$DATA_DIR/notes
export PSUITE_MINDMAP_DIR=$DATA_DIR/mindmap
export TASKDATA=$DATA_DIR/todo

use the folollowing commands to interact with psuite:

notes -> take notes, convert to markdown and preview
mm -> note down random thoughts ordered by datetime
task -> taskwarrior (to be installed separately)
"
