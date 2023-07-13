#!/bin/bash
# Clean up your system by removing unused dependencies.
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get clean

# Check the system storage taken by logs
journalctl --disk-usage

# Clear the logs that are older than 3 days.
sudo journalctl --vacuum-time=3d

# Check the disk storage taken by old snaps.
du -h /var/lib/snapd/snaps

# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
