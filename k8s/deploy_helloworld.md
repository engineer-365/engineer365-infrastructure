
# 在Kuberneties上部署一个Helloworld

##  1. 部署deployment: `kubectl apply -f helloworld/nginx-deployment.yaml`
  查看
  - `kubectl get deployments -l app=nginx`
  - `kubectl get pods -l app=nginx`

##  2. 部署service (NodePort): `kubectl apply -f helloworld/nginx-service.yaml`
  查看：
  - `kubectl get service -o wide -l app=nginx`
  - `curl http://k8s-node1.engineer365.org:32600`

## 参考
  
- Using kubectl to Create a Deployment
  https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/

- Using a Service to Expose Your App
  https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/
