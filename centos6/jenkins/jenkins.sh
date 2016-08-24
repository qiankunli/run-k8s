#!/bin/bash
set +e

REGISTRY_ADDRESS=192.168.3.56:5000
IMAGE_NAME=$JOB_NAME:$BUILD_NUMBER
FULL_IMAGE_NAME_WITHOUT_TAG=$REGISTRY_ADDRESS/$JOB_NAME
echo "IMAGE_NAME : $IMAGE_NAME"
LAST_BUILD_NUMBER=$(expr "$BUILD_NUMBER" - "1")
LAST_TWO_BUILD_NUMBER=$(expr "$BUILD_NUMBER" - "2")
LAST_IMAGE_NAME=$JOB_NAME:$LAST_BUILD_NUMBER
LAST_TWO_IMAGE_NAME=$JOB_NAME:$LAST_TWO_BUILD_NUMBER
echo "LAST_IMAGE_NAME : $LAST_IMAGE_NAME"
FULL_IMAGE_NAME=$REGISTRY_ADDRESS/$IMAGE_NAME
FULL_LAST_TWO_IMAGE_NAME=$REGISTRY_ADDRESS/$LAST_TWO_IMAGE_NAME

RC_NAME=$JOB_NAME

RE1=$(curl -XGET http://"$REGISTRY_ADDRESS"/v1/repositories/"$JOB_NAME"/tags/$LAST_TWO_BUILD_NUMBER)
if [[ "$RE1" != *error* ]];then
  RE2=$(curl -XDELETE http://"$REGISTRY_ADDRESS"/v1/repositories/"$JOB_NAME"/tags/$LAST_TWO_BUILD_NUMBER)
  if [ ! "$RE2" ]; then
    echo "docker registry detele image failure"
    exit -1
  fi
fi

/usr/bin/docker build -t $FULL_IMAGE_NAME $WORKSPACE | tee Docker_build_result.log

echo ">>>docker push image"

/usr/bin/docker push $FULL_IMAGE_NAME 

# use | as sed seperator ,s is for seperator
/bin/sed -i "s|job-name|$RC_NAME|g" $WORKSPACE/k8s/rc.yaml
/bin/sed -i "s|image-name|$FULL_IMAGE_NAME|g" $WORKSPACE/k8s/rc.yaml

rc_num=$(kubectl get rc -l name=$RC_NAME | wc -l)

if [ "$rc_num" == 0 ] ; then
    echo "there is no running rc $RC_NAME"
	/usr/local/bin/kubectl create -f $WORKSPACE/k8s/rc.yaml
else
    /usr/local/bin/kubectl rolling-update $RC_NAME --image=$FULL_IMAGE_NAME
fi

## remove old image and container
kubectl get nodes | awk 'NR>1' | awk '{print $1}' | while read node_ip
do
	image_num=$(/usr/bin/docker -H $node_ip:2375 images | awk '{print $1,$2}' | grep $FULL_IMAGE_NAME_WITHOUT_TAG | grep $LAST_TWO_BUILD_NUMBER | wc -l)
    echo "node_ip: $node_ip,image_name: $FULL_LAST_TWO_IMAGE_NAME,image_num: $image_num"
    if [ "$image_num" == 0 ] ; then
    	continue
    fi
    /usr/bin/docker -H $node_ip:2375 ps -a | grep $FULL_LAST_TWO_IMAGE_NAME | awk '{print $1}' | while read container_id
    do
    	echo "run >>> /usr/bin/docker -H $node_ip:2375 rm -f $container_id"
        /usr/bin/docker -H $node_ip:2375 rm -f $container_id
    done
	echo "run >>> /usr/bin/docker -H $node_ip:2375 rmi $FULL_LAST_TWO_IMAGE_NAME"
    /usr/bin/docker -H $node_ip:2375 rmi $FULL_LAST_TWO_IMAGE_NAME
done
