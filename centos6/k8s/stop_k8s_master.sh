#!/bin/bash

cur_process_id=$(ps -ef|grep kube-apiserver|grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-apiserver: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi

cur_process_id=$(ps -ef|grep kube-controller-manager|grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-controller-manager: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi

cur_process_id=$(ps -ef|grep kube-scheduler|grep -v grep |awk '{print $2}')
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-scheduler: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi

