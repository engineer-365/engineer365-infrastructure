# Kubernetes Master(Control-plane) 1 虚拟机

## 日常启动

  执行：`./up.sh`

vagrant ssh -c "sudo kubeadm token create --print-join-command"

`#kubeadm join k8s-master1.engineer365.org:6443 --token vhphuj.scr2clegn4ccmns7 --discovery-token-ca-cert-hash sha256:27c5c00d373f4bf2bb9f2cdd49498b89b8ec4a98fcb5620d960d42998e1081e5`
