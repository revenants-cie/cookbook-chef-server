#!/usr/bin/env bash

set -Eeuo pipefail

function delete_node() {
    local node=$1
    echo "Deleting node ${node}"
    knife node show "${node}"
    knife node delete "${node}" -y
    knife client delete "${node}" -y
}
# Find nodes that never converged
never_converged_nodes=$(knife status | awk '/has not yet converged./ { print $2 }')

for node in ${never_converged_nodes}
do
    delete_node "${node}"
done

# FInd nodes that didn't ping the server more than 240 hours
old_nodes=$(knife status | awk '/hours ago/ { if ($1 > 240) print $4 }' | sed 's/,$//')

for node in ${old_nodes}
do
    delete_node "${node}"
done
