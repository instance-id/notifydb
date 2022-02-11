#!/bin/bash

ARG=$1
ARG2=$@
SUB="log"

DB="test.db"
ENVFILE=".env"
SETTINGS="settings.toml"
LISTENER="notifydb_listener"

LISTENERSRC="$HOME/_dev/languages/rust/notifydb/target/debug/$LISTENER"
LISTENERDEST="$HOME/.files/notifydb"


function notifykill(){
    ps aux | grep -v grep | grep -v build | grep "$LISTENER" | awk '{print $2}' | xargs kill -9
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
RUST_LOG="debug" "$LISTENERDEST/$LISTENER" &! # Start listener