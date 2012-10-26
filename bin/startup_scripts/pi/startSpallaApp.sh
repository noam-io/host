#!/bin/sh

LD_LIBRARY_PATH=/usr/local/qt5pi/lib DEVICE_TYPE=pi nohup /home/pi/SpallaApp/SpallaApp > /home/pi/SpallaApp/out.txt 2> /home/pi/SpallaApp/error.txt < /dev/null &

echo "#!/bin/sh" > /home/pi/killSpallaApp.sh
echo "kill -9 $!" >> /home/pi/killSpallaApp.sh
chmod +x /home/pi/killSpallaApp.sh
