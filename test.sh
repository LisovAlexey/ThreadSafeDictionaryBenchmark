#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "Please provide a command as an argument."
  exit 1
fi

# Run the command specified by the argument
rm $@
swift run -c release $@ run $@ --cycles 5 --mode replace-all --min-size 4 --max-size 1000000 --smoothness 1 --iterations 4 --cycles 4
swift run -c release $@ render $@ chart.png --amortized false --linear-size --linear-time

