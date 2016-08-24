#!/bin/bash
log_dir=/var/log/flannel
if [ ! -d $log_dir ]; then
	mkdir $log_dir
fi
flanneld >> /var/log/flannel/flanneld.log 2>&1 &
