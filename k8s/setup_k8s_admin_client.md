# 设置从宿主机使用kubectl操作k8s集群

   我们需要把k8s admin client config从虚拟机里复制出来放到宿主机上。按以下步骤操作：

1. 在宿主机上执行以下命令，登录进入k8s-master1虚拟机

   ```shell
   cd virtualbox/k8s-master1
   vagrant ssh
   ```

2. 以下命令在k8s-master1内执行

   ```shell
   sudo su -
   cp -r /home/admin/.kube /vagrant/
   ```

3. 以上命令是把k8s admin client config复制到了虚拟机的/vagrant/目录里，这个/vagrant/是个特殊目录，被vagrant映射到了宿主机的当前工作目录，所以，退出虚拟机后，会看到当前工作目录中多出了一个.kube目录，把这个.kube目录复制到自己的用户目录下就可以了。

   `cp -r .kube $HOME/`

   然后，可以执行`kubectl get node`，看看是否能看到集群

   需要注意的是，因为我们的Vagrant VirtualBox虚拟机是使用的private network模式，这些虚拟机只能在当前宿主机上有效，所以，从宿主机外部是访问不到的。

4. 在宿主机上安装kubectl

   ```shell
   apt-get install -y apt-transport-https curl ebtables ethtool
   curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
   echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
   apt-get update && apt-get upgrade

   K8S_VER="1.20.1-00"
   apt-get install -y kubectl=${K8S_VER}
   apt-mark hold kubectl

   # set up bash completion for kubectl
   kubectl completion bash > /etc/bash_completion.d/kubectl
   ```
