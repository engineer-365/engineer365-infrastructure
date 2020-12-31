# 创建Jenkins Multibranch Github PR Job

  以下命令都是登录进入虚拟机后用sudo权限执行的，即，在宿主机上执行：

   `vagrant ssh`

   然后在虚拟机里`sudo su -`切换到root用户。

- ## 添加worker节点

   在k8s-master1虚拟机里，生成token和join命令行

   ```shell
   kubeadm token create --print-join-command
   ```

   打印出来的命令行类似：

   ```shell
   kubeadm join k8s-master1.engineer365.org:6443 --token 9vwdca.2i6f5sm6kp4xamjk --discovery-token-ca-cert-hash sha256:27c5c00d373f4bf2bb9f2cdd49498b89b8ec4a98fcb5620d960d42998e1081e5
   ```

   把上面这个命令行在所有worker节点虚拟机里用root权限执行里执行。

   默认情况下，token的有效期是24小时，如果token已经过期的话，可以使用以下命令重新生成：

   ```shell
   kubeadm token create
   kubeadm token generate
   ```

   或者，如果我们忘记了Master节点的token，可以使用下面的命令来查看：

   ```shell
   kubeadm token list
   ```

   如果找不到–discovery-token-ca-cert-hash的值，可以使用以下命令生成：

   ```shell
   openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
   ```

- ## 删除worker节点

   删除一个节点前，需要先drain上面的pod

   ```shell
   # 列出已有节点
   kubectl get nodes
   kubectl drain <待删除的节点的名字> --delete-emptydir-data --force --ignore-daemonsets
   kubectl delete node <待删除的节点的名字>
   
   # 等待node和相关联的calico-node, kube-proxy的pod消失
   watch kubectl get pod -n kube-system
   ```

   然后，在被删除的worker节点上，

   ```shell
   kubeadm reset
   rm -r /etc/cni/net.d
   ```

