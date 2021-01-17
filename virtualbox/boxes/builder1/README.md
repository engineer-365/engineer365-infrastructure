# 构建builder 1虚拟机

  这个虚拟机部署Jenkins 2.269。

  包括Jenkins的基本安装在内，这个镜像主要是做了以下事情：

  - 修改Jenkins启动参数，包括：
    - 设置清华大学站为Jenkins更新镜像站
    - 设置Jenkins使用headless模式
    - 设置`FOOTER_URL=https://builder.example.com:40043`
    - 设置Jenkins的timezone为`Asia/Shanghai`
    - 设置Jenkins使用CasC(Configuration As Code模式加载设置，这些设置包括：
      - 设置`JDK 11`
      - 设置`GIT`
      - 设置`Maven`
      
      CasC设置参见[./files/var/lib/jenkins/casc/tool.yaml](./files/var/lib/jenkins/casc/tool.yaml)
    
    启动参数设置参见[./files/etc/default/jenkins](././files/etc/default/jenkins)
  - 安装`Jenkins Plugin Manager 2.5.0`，设置清华大学站为Jenkins插件镜像站，然后安装常用的Jenkins插件，插件列表参见[./files/root/jenkins-tool/plugins.yaml](./files/root/jenkins-tool/plugins.yaml)
  - 设置阿里云为Jenkins的Maven公共仓库镜像

### 执行：`./build.sh`

### 部分jenkins docs的链接

  - Jenkins GITHUB：
    https://github.com/jenkinsci/docker/blob/master/README.md
  - https://www.jenkins.io/projects/jcasc/
  - https://github.com/jenkinsci/configuration-as-code-plugin
  - https://www.jenkins.io/doc/book/managing/groovy-hook-scripts/
  - https://plugins.jenkins.io/maven-plugin/
  - https://plugins.jenkins.io/docker-workflow/
  - https://www.jenkins.io/doc/book/pipeline/
  - https://plugins.jenkins.io/workflow-aggregator/
  - https://www.jenkins.io/doc/book/blueocean
  - https://docs.cloudbees.com/docs/cloudbees-ci/latest/cloud-admin-guide/github-branch-source-plugin
