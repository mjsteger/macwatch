#!/bin/bash

tmpFileLocation=/tmp/macWatch.plist
tmpPipeLocation=/tmp/macWatch.pipe
USAGE="Usage: $0 fileToWatch commandToRun"

if [ ! -p $tmpPipeLocation ]
then
    mkfifo $tmpPipeLocation
fi

if [ $# -lt 2 ];
then
    echo $USAGE
    exit 1
fi

fileToWatch=$1
shift
commandToRun=$@

trap "launchctl unload $tmpFileLocation; rm -rf $tmpPipeLocation; exit 1" SIGINT SIGTERM


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
 <key>StandardOutPath</key>
   <string>#PIPETOWRITE#</string>
</dict>
</plist>
EOF

sed -i.bak "s:#COMMANDTORUN#:$commandToRun:" $tmpFileLocation
sed -i.bak "s:#FILETOWATCH#:$fileToWatch:" $tmpFileLocation
sed -i.bak "s:#PIPETOWRITE#:$tmpPipeLocation:" $tmpFileLocation

launchctl load $tmpFileLocation

while true
do
    if read line < $tmpPipeLocation
    then
	echo $line
    fi
    sleep 1
done
