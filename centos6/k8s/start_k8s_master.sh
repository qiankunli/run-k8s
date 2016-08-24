#!/bin/bash
log_dir=/var/log/k8s/kube
std_out_file_dir=/var/log/k8s
etcd_servers=http://192.168.3.59:4001,http://192.168.3.57:4001,http://192.168.3.58:4001
master_ip=192.168.3.59
master_apiserver_port=8080
master=$master_ip:$master_apiserver_port
service_cluster_ip_range=10.10.1.0/24
kubelet_port=10250

if [ ! -d $log_dir ]; then
    mkdir -p $log_dir
fi

cur_process_id=$(ps -ef|grep kube-apiserver | grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-apiserver: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi

cur_process_id=$(ps -ef|grep kube-controller-manager|grep -v grep |awk '{print $2}')
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-controller-manager: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi

cur_process_id=$(ps -ef|grep kube-scheduler |grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-scheduler: $cur_process_id,kill it"
    kill -9 $cur_process_id
fi
echo "start..."

kube-apiserver --insecure-bind-address=0.0.0.0  \
	--insecure-port=$master_apiserver_port \
	--service-cluster-ip-range=$service_cluster_ip_range \
	--log_dir=$log_dir \
	--v=0 \
	--logtostderr=false \
	--etcd_servers=$etcd_servers \
	--allow_privileged=false  >> $std_out_file_dir/kube-apiserver.log 2>&1 &

kube-controller-manager  --v=0 \
	--logtostderr=false \
	--log_dir=$log_dir \
	--master=$master >> $std_out_file_dir/kube-controller-manager.log 2>&1 &

kube-scheduler  --master=$master \
	--v=0  \
	--log_dir=$log_dir  >> $std_out_file_dir/kube-scheduler.log 2>&1 &
