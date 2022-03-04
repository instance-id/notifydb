#!/bin/bash

BASEPATH=$(dirname "$0")

ARG=$1
ARG2=$@
SUB="log"
RUN="run"

DB="notify.db"
ENVFILE=".env"
SETTINGS="settings.toml"
LISTENER="notifydb_listener"

LISTENERSRC="$BASEPATH/target/debug/$LISTENER"
LISTENERDEST="$HOME/.config/notifydb"
source $ENVFILE

diesel migration run

function notifykill(){
    ps aux | grep -v grep | grep -v build | grep "$LISTENER" | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
}

echo "Stopping notifydb..."
notifykill

echo "Building notifydb... ${ARG}"

if [ "$ARG" == "--release" ]; then
    cargo build --release
elif [ "$ARG" == "--debug" ]; then
    cargo build
elif [ -n "$ARG" ]; then
  if [[ "$ARG2" == *"$SUB"* ]]; then
    RUST_LOG="DEBUG" cargo build --bin $ARG
  else
    cargo build --bin $ARG
  fi
else
    echo "No argument supplied"
    exit 1
fi

rm "$LISTENERDEST/$LISTENER"
cp "$LISTENERSRC" "$LISTENERDEST"

# If file does not exist, copy it
if [ ! -f "$LISTENERDEST/$ENVFILE" ]; then
    cp "$ENVFILE" "$LISTENERDEST"
fi

if [ ! -f "$LISTENERDEST/$DB" ]; then
    cp "$DB" "$LISTENERDEST"
fi

if [ ! -f "$LISTENERDEST/$SETTINGS" ]; then
    cp "$SETTINGS" "$LISTENERDEST"
fi

echo "Build complete!"

# shellcheck disable=SC1072,SC1073,SC1009,SC1035
if [[ "$ARG2" == *"$RUN"* ]]; then
    "$LISTENERDEST/$LISTENER" &!
fi

# RUST_LOG="debug" "$LISTENERDEST/$LISTENER" &! # Start listener