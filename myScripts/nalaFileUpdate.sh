#!/bin/sh

# track what are the manually installed packages
nala list -N | awk '!/^[├└]/ {print $1}' > ~/manuallyInstalled/nala/nalaFile &&

# track what are the manually installed packages with versions
nala list -N | grep -v "is installed" > ~/manuallyInstalled/nala/nalaFile-with-version

echo " manually installed packages tracking file: updated successfully"
