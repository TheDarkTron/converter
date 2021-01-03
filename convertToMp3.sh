#!/bin/bash

for f in "$@"
do
  lame --preset insane "$1" "$1.mp3"
done
