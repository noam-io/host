#!/bin/sh

mkdir -p /Users/progenitor/SpallaLog

DEVICE_TYPE=mac nohup /Applications/SpallaApp.app/Contents/MacOS/SpallaApp > /Users/progenitor/SpallaLog/out.txt 2> /Users/progenitor/SpallaLog/error.txt < /dev/null &

echo "#!/bin/sh" > /Applications/SpallaApp.app/Contents/MacOS/killSpallaApp.sh
echo "kill -9 $!" >> /Applications/SpallaApp.app/Contents/MacOS/killSpallaApp.sh
chmod +x /Applications/SpallaApp.app/Contents/MacOS/killSpallaApp.sh
