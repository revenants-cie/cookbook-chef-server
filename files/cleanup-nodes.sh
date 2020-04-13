#!/usr/bin/env bash

set -Eeuo pipefail

# Find nodes that never converged
unconverged_nodes=$(knife status | grep "has not yet converged." | awk '{ print $2 }')

for node in ${unconverged_nodes}
do
    knife node delete "${node}" -y
    knife client delete "${node}" -y
done

# FInd nodes that didn't ping the server more than 240 hours
old_nodes=$(knife status | grep "hours ago" | awk '{ if ($1 > 240) print $4 }' | sed 's/,$//')

for node in ${old_nodes}
do
    knife node delete "${node}" -y
    knife client delete "${node}" -y
done
