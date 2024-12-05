#!/bin/bash
# Ensure the script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., sudo ./script.sh)"
  exit 1
fi

echo "Starting system cleanup..."

# 1. Remove unused dependencies
echo "Removing unused dependencies..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean

# 2. Check and clean up journal logs
echo "Checking current journal logs disk usage..."
journalctl --disk-usage
echo "Cleaning up journal logs older than 3 days..."
sudo journalctl --vacuum-time=3d

# 3. Remove old Snap revisions
echo "Removing old Snap revisions..."
snap list --all | awk '/disabled/{print $1, $3}' | \
    while read snapname revision; do
        echo "Removing old Snap revision: $snapname, revision: $revision"
        snap remove "$snapname" --revision="$revision"
    done

# 4. Clear temporary files
echo "Clearing temporary files..."
sudo rm -rf /tmp/* /var/tmp/*

# 5. Clear cached memory (optional, but safe to run)
echo "Clearing cached memory..."
sync
sudo sysctl -w vm.drop_caches=3

# 6. Optional: Clear swap space if necessary
echo "Checking swap usage..."
free -h
echo "Clearing swap space..."
sudo swapoff -a && sudo swapon -a

# 7. Additional checks for disk usage in Snap directory
echo "Calculating storage used by Snap directory..."
du -h /var/lib/snapd/snaps

echo "System cleanup completed successfully!"
