#!/bin/bash

tmpFileLocation=/tmp/macWatch.plist

if [ $# -lt 2 ];
then
    echo $USAGE
    exit 1
fi

fileToWatch=$1
shift
commandToRun=$@

trap "launchctl unload $tmpFileLocation" SIGINT SIGTERM


cat <<EOF > $tmpFileLocation
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
 <string>MacWatcher</string>
 <key>ProgramArguments</key>
 <array>
  <string>#COMMANDTORUN#</string>
  <string>path modified</string>
 </array>
 <key>WatchPaths</key>
 <array>
  <string>#FILETOWATCH#</string>
 </array>
</dict>
</plist>
EOF

sed -i.bak "s:#COMMANDTORUN#:$commandToRun:" $tmpFileLocation
sed -i.bak "s:#FILETOWATCH#:$fileToWatch:" $tmpFileLocation

launchctl load $tmpFileLocation
sleep 9999999
# launchctl load $tmpFileLocation
# echo $PPID
# thisPID=`ps aux | grep $0|egrep -v grep | cut -d " " -f2`
# kill -20 $thisPID
