#!/bin/bash
#If non-empty, will use this string as identification instead of the actual hostname.
hostname_override=192.168.3.59
log_dir=/var/log/k8s/kube
std_out_file_dir=/var/log/k8s
master=http://192.168.3.59:8080
kubelet_port=10250
api_servers=http://192.168.3.59:8080
cluster_dns=10.10.1.100
cluster_domain=cluster.local
if [ ! -d $log_dir ]; then
    mkdir -p $log_dir
fi

cur_process_id=$(ps -ef|grep kube-proxy|grep -v grep |awk '{print $2}')
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of  kube-proxy: $cur_process_id kill it"
    kill -9 $cur_process_id
fi
cur_process_id=$(ps -ef|grep kubelet|grep -v grep |awk '{print $2}' )
if [ "x${cur_process_id}" != "x" ] ; then
    echo "current pid of kubelet: $cur_process_id kill it"
    kill -9 $cur_process_id
fi
echo "start..."
kube-proxy  --logtostderr=false \
	--v=0 \
	--hostname-override=$hostname_override \
	--master=$master   >> $std_out_file_dir/kube-proxy.log 2>&1 &

kubelet  --logtostderr=false \
	--v=0 \
	--allow-privileged=false  \
	--log_dir=$log_dir  \
	--address=0.0.0.0  \
	--port=$kubelet_port  \
	--hostname_override=$hostname_override  \
	--api_servers=$api_servers   >> $std_out_file_dir/kube-kubelet.log 2>&1 &
#	--cluster_dns=$cluster_dns \
#	--cluster_domain=$cluster_domain \
