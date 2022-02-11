#!/usr/bin/env bash

NOTIFYDB="notifydb"

BASEDIR="$HOME/_dev/languages/rust/notifydb"
NOTIFYDBSRC="$BASEDIR/target/debug/$NOTIFYDB"

echo "Running notifydb..."

cd "$BASEDIR" || exit
cargo run --bin notifydb

echo "Build complete!"