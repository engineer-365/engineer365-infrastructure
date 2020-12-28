# 构建Vagrant box的基础镜像

  我们约定全部VirtualBox虚拟机都使用Ubuntu 18 (Bionic)。
  
  下面步骤是构建一个[engineer365](https://github.com/engineer-365)共用的Ubuntu 18基础镜像:

1. 添加官方制作的ubuntu/bionic64的Vagrant box

   - 第一种方法是从我们的镜像网站下载，因为如果选择国外官网下载的话，因为Vagrant box文件比较大，有可能下载失败

    ```shell
    BOX_NAME="ubuntu-bionic-20201201"
    BOX_FILE="${BOX_NAME}.box"
    wget --quiet https://download.engineer365.org:40443/vagrant/box/hashicorp/${BOX_FILE}
    vagrant box add ${BOX_FILE} --name ${BOX_NAME} --force
    ```

   - 第二种方法，有代理加速的话，是可以从Vagrant官网直接下载添加Vagrant Box的，更简单一些：

    `vagrant box add ubuntu/bionic64`

    执行成功后，可以执行以下命令导出做个备份；另外，因为我们后面约定了这个Vagrant box的名字是`ubuntu-bionic-20201201`，所以需要重新导入一次。

     ```shell
    BOX_NAME="ubuntu-bionic-20201201"
    BOX_FILE="${BOX_NAME}.box"
    vagrant box repackage ubuntu/bionic64 virtualbox 20201201.0.0
    mv package.box ${BOX_FILE}
    vagrant box add ${BOX_FILE} --name ${BOX_NAME} --force
    ```

2. 制作后续其它虚拟机共用的Ubuntu 18基础镜像

   这个镜像主要是做了以下事情：

   - 设置清华大学作为Ubuntu镜像站
   - 系统更新(`apt-get update && apt-get -y upgrade`)
   - 修改timezone
   - 安装Docker和Docker compose，设置docker registry镜像
   - 添加admin用户和dev用户，生成SSH证书，加入sudoers
   - 添加环境变量`download_site=https://download.engineer365.org:40443`，后续的其它虚拟机都会用到。如需修改，请参见[../../script/vars.sh](../../script/vars.sh)
   
   除了环境变量`download_site`，[../../script/vars.sh](../../script/vars.sh)中还定义了其它一些变量，譬如organization的名字，构建后使用scp上传到engineer365下载站的URL等，这几个变量也是会被其它虚拟机用到，所以如果想自己完整的从零开始构建的湖，需要相应的修改。

   最后，执行：`./build.sh`
