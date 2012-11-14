#!/bin/sh

mkdir -p ~/SpallaLog

DEVICE_TYPE=mac nohup /Applications/SpallaApp.app/Contents/MacOS/SpallaApp > ~/SpallaLog/out.txt 2> ~/SpallaLog/error.txt < /dev/null &

echo "#!/bin/sh" > ~/killSpallaApp.sh
echo "kill -9 $!" >> ~/killSpallaApp.sh
chmod +x ~/killSpallaApp.sh
