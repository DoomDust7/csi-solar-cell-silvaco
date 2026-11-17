#!/bin/bash
# usage: queue.sh listfile   (lines: NAME|sets)   max 5 concurrent runs (2 GB session cap)
while IFS='|' read -r n s; do while [ $(pgrep -fc 'run1.sh') -ge 5 ]; do sleep 5; done; ./run1.sh "$n" "$s" & sleep 2; done < "$1"; wait
