# 安装新的Jenkins插件

```shell
NEW_PLUGIN=<plugin id>:<plugin version>
java -jar /root/jenkins-tool/jenkins-plugin-manager.jar \
     --verbose \
     --jenkins-update-center https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/dynamic-${JENKINS_VER}/update-center.actual.json \
     --jenkins-experimental-update-center https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/experimental/update-center.actual.json \
     --jenkins-plugin-info https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/current/plugin-versions.json \
     --plugin-download-directory /var/lib/jenkins/plugins/ \
     --plugins ${NEW_PLUGIN}

# restart jenkins
systemctl restart jenkins
```
