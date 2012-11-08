#!/bin/sh

mkdir -p /Users/progenitor/SpallaLog

DEVICE_TYPE=mac nohup /Applications/SpallaApp.app/Contents/MacOS/SpallaApp > /Users/progenitor/SpallaLog/out.txt 2> /Users/progenitor/SpallaLog/error.txt < /dev/null &

echo "#!/bin/sh" > /Users/progenitor/killSpallaApp.sh
echo "kill -9 $!" >> /Users/progenitor/killSpallaApp.sh
chmod +x /Users/progenitor/killSpallaApp.sh
