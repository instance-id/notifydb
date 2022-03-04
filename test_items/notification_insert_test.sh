#!/bin/bash

# iterate sending notification 10 times with notify-send
for i in {1..100}; do
    notify-send "Title $i" "Body $i"
    sleep 0.5
done
