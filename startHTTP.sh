#!/bin/bash

docker ps | grep -q lighttpd && \
        { echo "LIGHTTPD ALREADY RUNNING"; echo "STOP IT WITH 'docker stop lighttpd' IF YOU DON'T WANT THAT"; docker ps -a; exit 1; }

echo -e "\nlighttpd not already running..."
echo -e "\nWhat directory do you want to share?"
echo "We assume '/piserver/samba/'"
echo "So, give me this: Storage/Video/Shows/DHMIS/"

read -p "Directory: " DIR

echo -e "\nUsing '/piserver/samba/$DIR' as the HTTP share!"
echo "If that's not what you want, ^C out or be doomed forever!"
echo -e "Sleeping 5 seconds..."
sleep 5

docker run --rm -d --net=host \
        --mount type=bind,source=/piserver/samba/$DIR,destination=/var/www/localhost/htdocs,readonly \
        --mount type=bind,source=/home/pi/lighttpd-docker/lighttpd.conf,destination=/etc/lighttpd/lighttpd.conf \
        --name lighttpd lighttpd-docker:1.1.1

echo -e "\nChecking if the container is still running after 10 seconds..."
sleep 10
docker ps | grep -q lighttpd && \
        { echo "lighttpd still running, nice!"; echo -e "Stop it with 'docker stop lighttpd' whenever you want.\n"; docker ps; exit 0; } || \
        { echo "LIGHTTPD NOT RUNNING!"; echo "YOU FUCKED SOMETHING UP!"; docker ps -a; exit 1; }
