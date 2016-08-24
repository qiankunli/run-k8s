## k8s 安装

本项目列出了部分环境下，安装k8s集群用到的配置文件

参考文档:http://my.oschina.net/dxqr/blog/607854

下面以centos6为例（需要用户根据自己的环境更改部分配置）

### etcd + flannel 搭建基本的网络环境

下载etcd和flannel

etcd的配置文件参见`centos6/sysconfig`，启动脚本参见`centos6/init.d`，确认etcd启动成功

然后在每个节点上执行

	mk-docker-opts.sh -i
	source /run/flannel/subnet.env
	rm /var/run/docker.pid
	ifconfig docker0 ${FLANNEL_SUBNET}
	重启docker

mk-docker-opts.sh 包含在flannel.tar.gz中

### 安装和启动k8s

kubernetes.tar.gz github上下载并解压后，到`kubernetes/server/kubernetes/server/bin`目录下拷贝相关程序到`/usr/local/bin`

|master|node|
|-|-|
|api-server,controller-manager,scheduler|kubelet,kube-proxy|

执行`k8s/start_k8s_master.sh`启动master，`k8s/start_k8s_minion.sh`启动node。

## 注意事项

1. etcd ，在采用static集群模式的情况下，增加新的节点时，要清空数据文件夹
2. kubernetes 更新版本后，一些老数据可能不对，这时要`etcdctl rm -f /registry``

## 一些坑

1. k8s在工作时，会下载一些google的docker image，国内下载不了，需要先看下日志，找到image(通过docker hub或者阿里云)，想其他的办法下载到node上。
2. k8s v1.2.0 创建一个pod时是一个job，如果创建失败，会一直重试，最好设置下超时间

## jenkins 

jenkins脚本基本思路

1. build num 作为镜像的tag，如果是新项目，就create rc,否则 rolling-update rc
2. 项目中包含k8s/rc.yaml文件，在脚本中临时替换yaml中的name和image name
3. 删除node老镜像时，删除上上一个镜像，因为rolling-update后，上一个镜像可能还有容器在运行
4. registry中删除上上一个镜像，方便出现问题时回滚。即registry和本地都保留上一个版本的镜像

