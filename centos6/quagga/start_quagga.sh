#!/bin/bash

APP_NAME=index.alauda.cn/georce/router

echo '>>> Get old container id'
CID=$(docker ps -a | grep "$APP_NAME" | awk '{print $1}')
echo $CID
if [ "$CID"x != ""x ];then 
    echo '>>> Stopping old container'
    /usr/bin/docker rm -f $CID
fi

docker run -itd --name=router --privileged --net=host index.alauda.cn/georce/router
