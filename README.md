# 云原生的微服务开发工程示范 - 基础设施的代码化管理

  这里是[“云原生的微服务开发工程示范” engineer-365/cloud-native-micro-service-engineering](https://github.com/engineer-365/cloud-native-micro-service-engineering)的子项目，这个子项目的目标，是遵循`IaC（基础设施代码化管理Infrastructure As Code)`和`GitOps`的思想来学习和实践对微服务开发相关基础设施的部署、管理和监控。

  关于`IaC`:
  > As a best practice, infrastructure-as-code mandates that whatever work is needed to provision computing resources it must be done via code only.

  > 作为最佳实践，基础设施及代码授权所有准备计算资源所需要做的工作都可以通过代码来完成

  关于`GitOps`：
  > An operating model for Kubernetes and other cloud native technologies, providing a set of best practices that unify deployment, management and monitoring for containerized clusters and applications.
  > A path towards a developer experience for managing applications; where end-to-end CI/CD pipelines and git workflows are applied to both operations, and development.

  GitOps 四项原则
  > - 以声明的方式描述整个系统
  > - 系统的目标状态通过 Git 进行版本控制
  > - 对目标状态的变更批准后将自动应用到系统
  > - 驱动收敛 & 上报偏离

  遵循以上原则，我们会尽量地用代码化的、声明式的、命令行的方式实现，无论文档还是代码都放git，以git作为single source of truth，以git PR作为运维操作手段和入口，从而实现：
  - 标准化，可复制，对开发人员透明
  - 提高平均部署时间（MTTD)和平均修复时间（MTTR），可以稳定快速的部署新环境或修复，可以自动连续部署应用，不再依赖手动运维
  - 使用git版本控制回滚、升级、更改和追踪，用git PR审查包括权限在内的一切变更；开发人员不需要知道如何操作运维平台和部署交付流程，所有操作使用git PR完成
  - 不只是代码变更，即使其它基础设置等的变更也需要通过自动测试

  参见：
  - https://www.jianshu.com/p/8f5b3cbf0928 (中文)
  - https://zhuanlan.zhihu.com/p/43002417 (中文)
  - https://www.jianshu.com/p/ac3722ddf0de (中文)
  - http://saas.ctocio.com.cn/saas/2020/1225/56425.html (中文)
  - https://www.cnblogs.com/rancherlabs/p/12450473.html (中文)
  - https://www.oreilly.com/library/view/infrastructure-as-code/9781491924334/ (英语)
  - https://www.ibm.com/cloud/learn/infrastructure-as-code (英语)
  - https://www.weave.works/blog/gitops-operations-by-pull-request (英语)
  - https://www.gitops.tech/ (英语)

<hr>

## V1 (即第1阶段)
## 使用Vagrant管理和部署若干个Virtual Box虚拟机，在虚拟机上建立最基本的测试环境

## 分为IaaS层和PaaS两层
     
   1. IaaS层是基础的虚拟机，对应公有云的虚拟机。V1里使用Vagrant和VirtualBox实现，后续版本里最终使用公有云上的虚拟机机替换。但V1同时也是个人使用的本地开发环境会一直保留

   2. PaaS层是以K8S为核心，对应公有云的K8S集群和公有云的其它中间件服务。V1里使用shell script完成安装设置和管理。后续考虑使用Ansible，Nomad，Terraform等工具
   
   
   我们以[https://github.com/engineer-365/fleashop-server](https://github.com/engineer-365/fleashop-server)和[https://github.com/engineer-365/fleashop-fronter](https://github.com/engineer-365/fleashop-fronter)分别作为前后端应用，实现：

   1. 1台虚拟机部署Jenkins, 1台虚拟机部署Harbor docker registry, 1台虚拟机部署MySQL单机, 1台虚拟机部署K8S Master, 3台虚拟机部署K8S Worker
   2. 应用代码以PR形式提交到Github后，自动触发Jenkins（builder 1虚拟机）上的构建
   3. 构建过程中，执行单元测试和集成测试
   4. 构建成功后，推送docker image到Harbor（store 4）虚拟机；然后，用Jenkins SSH(push模式)连接到K8S master，使用kubectl部署应用 
  
  ### 1. 目录结构

   ```shell
   ├── jenkins
   └── virtualbox              # 所有和virtualbox虚拟机有关的都在这个目录
       ├── boxes               # 用于构建各虚拟机的vagrant box
       │   ├── builder         # 所有builder虚拟机的共用基础box, 扩展了ubuntu-bionic, 安装JDK/GO/Node/Maven等构建环境
       │   ├── builder1        # 第一个builder虚拟机的vagrant box, 扩展了builder，是Jenkins主节点
       │   ├── k8s-base        # 所有K8S虚拟机的vagrant box
       │   ├── k8s-master1     # K8S Master 1虚拟机的vagrant box, 扩展了k8s-base
       │   ├── store1          # 5个store虚拟机之一的vagrant box，MySQL主节点
       │   ├── store4          # 5个store虚拟机之一的vagrant box，Harbor Docker Registry
       │   └── ubuntu-bionic   # 基础的ubuntu 18 (bionic) vagrant box, 扩展了官方的ubuntu bionic box，增加了docker等共用的软件包
       ├── builder1            # 第一个builder虚拟机，是Jenkins主节点，使用从boxes/builder1构建好的vagrant box启动
       ├── k8s-master1         # K8S Master 1虚拟机，使用从boxes/k8s-master1构建好的vagrant box启动
       ├── k8s-node1 (~5)      # K8S Worker 1~5虚拟机，使用从boxes/k8s-base构建好的vagrant box启动
       ├── script              # 构建、启动等共用的脚本，由各虚拟机的构建/启动脚本间接调用
       │   ├── box_names.sh    # 所有Vagrant box的命名
       │   ├── boxes.sh        # 虚拟机的启动/构建等工具脚本
       │   ├── ip_and_hosts.sh # 虚拟机的ip/host分配
       │   └── vars.sh         # 一些共用的shell variables
       ├── store1              # 5个store虚拟机之一，MySQL主节点，使用从boxes/store1构建好的vagrant box启动
       ├── store4              # 5个store虚拟机之一，Harbor Docker Registry，使用从boxes/store4构建好的vagrant box启动
       └── etc_hosts           # 各虚拟机的ip和host对照表，构建时会自动生成；在部署内部DNS之前，每个虚拟机都会复制一份到作为自己的/etc/hosts。
   ```

   主要分为2大类目录：

   1. 根目录里的[./virtualbox](./virtualbox)里是目前阶段使用的Vagrant + VirtualBox的所有代码，这里面进一步分为两大类子目录：
      
      - 除了script等辅助目录，每个非boxes子目录下放的都是某一个虚拟机的启动脚本和Vagrant代码。
        * 注：如果不想自己构建，那么可以使用我们已经构建好的Vagrant Box，启动脚本会检测和下载
      
      - [./virtualbox/boxes](./virtualbox/boxes)子目录下是可以用于自己构建虚拟机的Vagrant代码，如果不想自己构建，那么可以忽略。
        [./virtualbox/boxes](./virtualbox/boxes)下的每个子目录的结构都相似，譬如子目录[./virtualbox/boxes/builder1](./virtualbox/boxes/builder1)有如下结构：

        ```shell
        /virtualbox/boxes/builder1
        ├── build.sh           # 启动构建的Bash脚本，在宿主机上执行
        ├── provision.sh       # 虚拟机启动成功后的初始化脚本，在虚拟机内执行，譬如安装JDK。provision.sh尽可能做到不依赖于Vagrant，以便能够在后续阶段里复用
        ├── files              # 虚拟机启动成功后会拷贝进去的文件，不同的虚拟机不一样，和需要安装设置的软件包有关
        │   └── etc
        │   │    ├── default
        │   │    │   └── jenkins
        │   │    └── nginx
        │   │        └── sites-enabled
        │   │            ├── mirrors.jenkins-ci.org.conf
        │   │            └── updates.jenkins-ci.org.conf
        │   └── root
        │        └── jenkins-tool
        │            ├── jenkins.yaml
        │            └── plugins.yaml
        ├── README.md
        └── Vagrantfile        # Vagrant的虚拟机描述文件
        ```
      
   2. 根目录下的其它目录是针对某一个具体软件包的，和虚拟机无关，譬如[./jenkins](./jenkins)里是如何在Jenkins中创建job等的文档和工具代码。
      
  ### 2. 准备工作 - 安装Vagrant和VirtualBox

  #### 2.1 安装VirtualBox (6.1.16)
  
  VirtualBox的安装包可以在下列服务器下载：
  - 官网：https://download.virtualbox.org/virtualbox/6.1.16
  - 清华大学镜像：https://mirrors.tuna.tsinghua.edu.cn/virtualbox/6.1.16
  - engineer365的下载站：https://download.engineer365.org:40443/virtualbox/6.1.16

  各个操作系统都有对应的GUI安装包。
  
  Ubuntu server上，可以用以下命令行安装(从engineer365下载)：
  
  ```shell
  # 设置timezone
  TIMEZONE="Asia/Shanghai"
  sudo ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
  sudo echo ${TIMEZONE} > /etc/timezone

  # 安装一些相关工具
  sudo apt-get install -y linux-headers-$(uname -r) build-essential gcc make python zip cmake uuid tree jq

  # 下载安装包
  VIRTUALBOX_DEB=virtualbox-6.1_6.1.16-140961~Ubuntu~$(lsb_release -cs)_amd64.deb
  wget "https://download.engineer365.org:40443/virtualbox/6.1.16/${VIRTUALBOX_DEB}"
  sudo dpkg -i ${VIRTUALBOX_DEB}
  sudo apt --fix-broken install

  # 可选：设置缺省的VirtualBox虚拟机数据目录，默认的数据目录是 ${HOME}/'VirtualBox VMs'
  VM_DIR=/data/virtualbox_vm
  sudo mkdir -p ${VM_DIR} 
  sudo chown -R ${USER}:${USER} ${VM_DIR}
  VBoxManage setproperty machinefolder ${VM_DIR}
  ```

  #### 2.2 安装Vagrant (2.2.14)
  
  Vagrant的安装包可以在下列服务器下载：
  - 官网：https://www.vagrantup.com/downloads
  - engineer365的下载站：https://download.engineer365.org:40443/vagrant/

  各个操作系统都有对应的GUI安装包。
  
  Ubuntu server上，可以用以下命令行安装(从engineer365下载)：

  ```shell
  VAGRANT_DEB=vagrant_2.2.14_x86_64.deb
  wget "https://download.engineer365.org:40443/vagrant/${VAGRANT_DEB}"
  sudo dpkg -i ${VAGRANT_DEB}
  ```
  #### 2.3 安装必须的Vagrant插件

   - 我们用到了Vagrant的“disks”功能，是vagrant的实验特性，所以需要设置VAGRANT_EXPERIMENTAL环境变量来启用
   ```shell
   sudo echo 'export VAGRANT_EXPERIMENTAL="disks"' >> /etc/profile
   source /etc/profile
   ```

  - vagrant-vbguest(0.28.0)是一个vagrant插件，用于安装VirtualBox Guest扩展
  ```shell
  vagrant plugin install vagrant-vbguest
  ```

  - vagrant-disksize (0.1.3)是一个vagrant插件，用于修改虚拟机的磁盘大小（官方的Ubuntu 18 box的磁盘仅10G，完全不够用）
  ```shell
  vagrant plugin install vagrant-disksize
  ```

  #### 2.4 安装kubectl

    我们不在宿主机上安装Kubernetes集群，但是为了方便操作虚拟机里的Kubernetes集群，需要安装kubectl。

    Windows和Mac下Docker安装已经带有kubectl，所以这里只以Ubuntu 20为例说明Linux上的安装：
    ```shell
    sudo su -
    curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
    apt-get update && apt-get upgrade
    apt-get install -y kubectl=1.20.1-00
    apt-mark hold kubectl
    ```

    另外，包括Windows和Mac在内，都需要把`192.168.50.151 k8s-master1.engineer365.org`加入/etc/hosts：
    ```shell
    echo "192.168.50.151    k8s-master1.engineer365.org" >> /etc/hosts
    echo "192.168.50.171    k8s-node1.engineer365.org" >> /etc/hosts
    echo "192.168.50.172    k8s-node2.engineer365.org" >> /etc/hosts
    echo "192.168.50.173    k8s-node3.engineer365.org" >> /etc/hosts
    echo "192.168.50.174    k8s-node4.engineer365.org" >> /etc/hosts
    echo "192.168.50.175    k8s-node5.engineer365.org" >> /etc/hosts
    ```

  ### 3. 启动虚拟机
     
   如果启动脚本检测到宿主机中没有相应版本的Vagrant box，那么启动脚本会从[https://download.engineer365.org:40443/vagrant/box/](https://download.engineer365.org:40443/vagrant/box/)下载我们预先构建好的Vagrant box。
    
   - [x] builder 1虚拟机: [./virtualbox/builder1/](./virtualbox/builder1/)
   - [ ] store 1和store 4虚拟机: [./virtualbox/store1/](./virtualbox/store1/)
   - [x] K8S master 1虚拟机: [./virtualbox/k8s-master1/](./virtualbox/k8s-master1/)
   - [x] K8S node 1 ～ 5虚拟机: [./virtualbox/k8s-node1/](./virtualbox/k8s-node1/)，至少启动3个

  ### 4. 可选：构建虚拟机

   想完整的从零开始构建全部虚拟机的话，请按照以下顺序执行构建（构建过程比较耗时）：

   1. [x] [./virtualbox/boxes/ubuntu-bionic/](./virtualbox/boxes/ubuntu-bionic)
   2. [x] [./virtualbox/boxes/builder/](./virtualbox/boxes/builder)
   3. [x] [./virtualbox/boxes/builder1/](./virtualbox/boxes/builder1/)
   4. [ ] [./virtualbox/boxes/store1/](./virtualbox/boxes/store1/)
   5. [ ] [./virtualbox/boxes/store4/](./virtualbox/boxes/store4/)
   6. [x] [./virtualbox/boxes/k8s-base/](./virtualbox/boxes/k8s-base/)
   7. [x] [./virtualbox/boxes/k8s-master1/](./virtualbox/boxes/k8s-master1/)

   构建的输出物是Vagrant box，是给Vagrant对虚拟机做的打包格式，以`.box`作为文件扩展名。

<hr>



## 其它阶段的目标

   - V2: 使用Ansible和Nomad部署完整的虚拟机功能集群，用于测试环境，包括：
     - [ ] 支持私有部署的Gitlab
     - [ ] 使用Ranchor管理Kubernetes集群
     - [ ] 使用Nexus或JFrog做artifactory
     - [ ] 使用ArgoCD/gitkube/Jenkins X/FluxCD持续部署到Kubernetes
     - [ ] 部署MySQL master/slave
     - [ ] 部署分布式缓存：Redis
     - [ ] 部署全文检索和日志管理：ELK (Elasticsearch + Logstash + Kibana):
     - [ ] 部署Consul和Git2Consul，集中管理配置
     - [ ] 部署Vault，管理MySQL等密码
     - [ ] 部署OpenTracing/Jaeger，追踪分布式调用链路
     - [ ] 部署Zabbix、Prometheus和Grafana，监控报警
     - [ ] 持续集成中支持压力测试和性能测试

   - V3：高可用化(High Availability)和可扩展(Scalable)
     - [ ] 实现对IaC的自动化测试
     - [ ] 升级成多个Jenkins worker
     - [ ] 升级成高可用MySQL集群：MySQL Router + Group Replication + MySQL Shell
     - [ ] Redis Sentinel
     - [ ] ...

   - V4
     - [ ] 多集群环境
     - [ ] 寻找赞助商，对接公有云API，Terraform部署生产环境到公有云
     - [ ] 支持混合云部署（Openstack私有云+某个公有云）
     - [ ] ...

   - V5
     - [ ] 大数据测试环境
     - [ ] 彻底去除不符合IaC和GitOps的部分
     - [ ] 尝试各种替代选项（包括github的替代选项）
     - [ ] ...

<hr>

## 常见问题

### 1. 为什么使用Vagrant[https://vagrantup.com/] ？
   
   我们使用Vagrant管理VirtualBox虚拟机，Vagrant使我们可以:
   - 用文本文件(Vagrantfile)声明式地描述目标虚拟机的物理配置
   - 用命令行执行VirtualBox操作
   - 支持shell script和Ansible的provisioning
   - Vagrant的box是打包好的构建好的虚拟机（类似Docker image），从而允许我们可以跳过虚拟机的构建过程直接部署预先构建好的虚拟机。
   
### 2. 为什么使用VirtualBox，而不是VMWare / KVM / Xen ... ？

   VirtualBox开源、免费，跨平台支持Windows/Mac OS/Linux，对开发者来说简单方便。后续我们也考虑在混合云/私有云环境下支持VMWare/KVM/Xen，但重点还是和公有云的集成，而VirtualBox作为个人开发环境会一直使用下去。

### 3. 是否支持非Ubuntu虚拟机，譬如Windows虚拟机 ？

  IaC代码由宿主机和虚拟机两部分组成：
  
  1. 宿主机目前只在Mac OS X BigSur和Ubuntu 20 server上验证通过，理论上，只要能安装VirtualBox和Vagrant都可以安装，包括Windows宿主机。Vagrant本身是跨平台的，支持Windows宿主机需要把Bash script用Windows Powershell改写
  2. 虚拟机操作系统是Ubuntu 18 server，移植到到CentOS等其它Linux虚拟机应该容易。目前不考虑支持Windows虚拟机
    
### 4. 如何参与和贡献代码？
    
  项目刚启动，目前处于第一阶段。

  开源项目没有真正的门槛（门槛在于个人自身意愿），所以谁想参加都可以。

  参加开源项目也并不只是写代码，因为很多人会因为时间精力等各种原因还没法直接参与代码开发。其实做贡献的方式有很多种，除了直接提交代码PR，贡献的重要程度按顺序排列如下，我们非常欢迎：
    
  - 帮助审核PR：https://github.com/engineer-365/engineer365-infrastructure/pulls
    
      审核PR首先需要加入团队以获取成员资格，如何加入请参见[https://github.com/engineer-365/cloud-native-micro-service-engineering/blob/main/members.md](https://github.com/engineer-365/cloud-native-micro-service-engineering/blob/main/members.md)。
      PR审核并不只是点击"Approve"按钮，PR审核意味着责任，例如对于这个infrastructure子项目，目前的IaC代码还没做到自动验证，所以审核PR时需要帮助做验证（部分验证或全部验证都可以）。

  - 参与discussion：https://github.com/orgs/engineer-365/teams/engineers-engineer-365/discussions
  - 找bug、提Issue：https://github.com/engineer-365/engineer365-infrastructure/issues
  - 英文文档
  - 其它方式方法也请提建议！

  在各种贡献方式中，PR是最硬核的对参与程度的衡量，因为PR一合并就会被Github自动记入贡献者名单，在项目首页就看得到。

  我们特别渴求大家能贡献以下方面的PR：

  1. 支持Windows宿主机，主要是需要用Powershell重写宿主机部分的Bash script
  2. 用以自动化验证IaC的Jenkins Pipeline
  3. 使用Jenkins命令行工具管理Jenkins job
  4. 使用Harbor API管理Harbor
  5. 支持外国开发者，譬如给脚本增加语言条件判断以可选地设置Ubuntu镜像
  6. 支持Centos等Linux虚拟机
  7. 用Ansible替换Bash script
  8. 支持VMWare虚拟机
  9. 支持WSL虚拟机
   
### 5. 虚拟机环境对宿主机有什么要求？
  需要一台物理机器。
  
  因为通常需要启动6各以上虚拟机，每各虚拟机的内存设置为4GB（Jenkins那台是8GB），所以建议至少32G物理内存，或者自行修改Vagrantfile降低内存大小设置。

  当然，也可以只是试试其中一个虚拟机。
  
### 6. Vagrant + Bash script + VirtualBox这个组合显然不会用于实际环境，会换掉吗？
  第一阶段使用这个组合是因为个人开发环境下使用方便，后续阶段里，在测试环境和生产环境里是会被替换掉的，但是在个人开发环境中，这个组合会一直使用下去。

### 7. 大部分软件包都需要从国外网站下载，是不是会很慢，甚至下载不下来？
  我们的构建工具/脚本会尽可能从国内镜像下载，譬如Ubuntu server和Jenkins的plugin都是从清华大学的镜像站下载。对于那些还没找到镜像的包，譬如Ubuntu 18的Vagrant box，我们已经下载好了，可以在[https://download.engineer365.org:40443/](https://download.engineer365.org:40443)找到。

### 8. 出错：/home/qiangyt/engineer365/repos/engineer365-infrastructure/virtualbox/boxes/ubuntu-bionic/ubuntu-bionic-18.04-cloudimg-console.log (VERR_FILE_NOT_FOUND)

  出现以下报错时是已知Issue #3 (https://github.com/engineer-365/engineer365-infrastructure/issues/3)。

  ```shell
  There was an error while executing `VBoxManage`, a CLI used by Vagrant
  for controlling VirtualBox. The command and stderr is shown below.

  Command: ["startvm", "bed3796d-9c02-453d-a0e9-0022a8cabc70", "--type", "headless"]

  Stderr: VBoxManage: error: RawFile#0 failed to create the raw output file /home/qiangyt/engineer365/repos/engineer365-infrastructure/virtualbox/boxes/ubuntu-bionic/ubuntu-bionic-18.04-cloudimg-console.log (VERR_FILE_NOT_FOUND)
  VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component ConsoleWrap, interface IConsole
  ```

  原因是我们预先构建的Vagrant box里依赖于基础镜像的一个目录，目前还没找到解决办法，workaround是建立一个空目录：

  ```sudo mkdir -p /home/qiangyt/engineer365/repos/engineer365-infrastructure/virtualbox/boxes/ubuntu-bionic/```

  然后```vagrant destroy```，并重新执行。


## TODO

  1. 重构Vagrant box的复用层级
   
     目前的扩展层次已经有4层，譬如: ubuntu bionic官方box -> engineer365专用基础box -> builder box -> builder1 box。这样的方式虽然达到了复用安装的各种软件包的目的，但是层级多了结构复杂。一方面，这个项目的主要目标是学习和示范，不是开发框架，结构复杂的示例不够简单明了，不方便学习参考；另一方面，VirtualBox只适合本地环境开发使用，用结构复杂的代价获得层次化的可复用的box，这点对于线上应用来说也没有意义。
     所以，改进的方向就是简化，想法是：
     1. 最多两层。尽可能通过provision script的复用做到复用，而不是box层面的复用
     2. 做provision script的生成器，生成器可以为了高度复用而做得复杂，但生成的provion script不必复用，反而应该是虽然冗长重复性大但直接了当和平铺直叙的。
       （也许，生成器可以是另一个仓库?）
     3. 用声明式的方式而不是provision script的过程式脚本。
        (所以，直接开始用Ansible?)

