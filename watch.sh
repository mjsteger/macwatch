#!/bin/bash

killerLocation=/usr/local/bin/killer.sh
USAGE="Usage: $0 fileToWatch commandToRun"

if [ $# -lt 2 ];
then
    echo $USAGE
    exit 1
fi

fileToWatch=`pwd`/$1
shift
pidOfFile=$1
shift
commandToRun=$@

trap "launchctl unload $tmpFileLocation; rm -rf $tmpPipeLocation; exit 1" SIGINT SIGTERM

tmpFileLocation=/tmp/macWatch.plist.$pidOfFile

cat <<EOF > $tmpFileLocation
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
 <string>MacWatcher#PIDOFFILE#</string>
 <key>ProgramArguments</key>
 <array>
  <string>#KILLERLOCATION#</string>
  <string>#PIDOFFILE#</string>
 </array>
 <key>WatchPaths</key>
 <array>
  <string>#FILETOWATCH#</string>
 </array>
</dict>
</plist>
EOF

sed -i.bak "s:#KILLERLOCATION#:$killerLocation:" $tmpFileLocation
sed -i.bak "s:#PIDOFFILE#:$pidOfFile:" $tmpFileLocation
sed -i.bak "s:#FILETOWATCH#:$fileToWatch:" $tmpFileLocation

launchctl load $tmpFileLocation
