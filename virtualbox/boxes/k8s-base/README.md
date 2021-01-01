# Kubernetes节点虚拟机的基础镜像

  这个是K8S master节点和worker节点共用的基础镜像。
  
  这个镜像主要是为后续使用kubeadm安装k8s做准备工作，包括：

  - 安装kubelet kubeadm kubectl，目前版本是1.20.1
  - 拉取相关的docker image

### 执行：`./build.sh`
