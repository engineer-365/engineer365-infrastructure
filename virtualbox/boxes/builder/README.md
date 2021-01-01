# builder（构建虚拟机）的基础镜像

  是builder1等CI/CD虚拟机的基础镜像，用于部署Jenkins等服务。

  这个镜像主要是做了以下事情：

  - 安装`GOLANG （1.14.13）`，设置`GOPATH`、`GOPROXY=https://goproxy.io`、`GO111MODULE=on`
  - 安装`Open JDK 11（11.0.9.1+1）`，设置`JAVA_HOME`，默认使用JDK 11
  - 安装`Open JDK 8 （8u275-b01）`
  - 安装`Maven 3.6.3`
  - 安装`JMeter 5.4`
  - 安装`Node.js 14.15.1`
  - 安装`Gradle 6.7.1`

### 执行：`./build.sh`
