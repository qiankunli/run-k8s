#!/bin/bash

cur_process_id=$(ps -ef|grep kube-proxy | grep -v grep |awk '{print $2}')
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-proxy: $cur_process_id kill it"
    kill -9 $cur_process_id
fi
cur_process_id=$(ps -ef|grep kubelet |grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of kubelet: $cur_process_id kill it"
    kill -9 $cur_process_id
fi
