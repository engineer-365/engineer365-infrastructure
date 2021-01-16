  
# 系统初始化设置
## 设置admin的密码
  
  打开浏览器，访问https://docker.example.com:443
    - 用户名：admin，初始密码Engineer12345
    - 右上角菜单：admin -> 修改密码

## 初始化Engineer365的项目和用户：
  
  - 选择左侧菜单“系统管理”/“用户管理”/“创建用户”
    - 为每一个团队成员创建一个用户账号
    - 为builder(jenkins)创建一个用户账号
      - 用户名：engineer365-builder
      - 邮箱：engineer365-builder@mail.example.com
      - 密码： ***
    - 为deployer(k8s)创建一个用户账号
      - 用户名：engineer365-deployer
      - 邮箱：engineer365-deployer@mail.example.com
      - 密码： ***
  
  - 选择左侧菜单“项目”/“新建项目”
    - 使用Github organization名字创建项目名称：example.com，访问级别：不公开
    - 创建后点击进入该项目，选择“成员”tab，点击“+成员”
      - 把每一个团队成员都加入成为“受限访客”（Limited Guest）。
      - 把engineer365-builder用户加入成为“开发者”（Developer）。
      - 关于项目成员角色，参见https://goharbor.io/docs/2.0.0/administration/managing-users/user-permissions-by-role/

   - 从这个docker registry拉取镜像时前需要一次性登录
     - docker login -u 用户名 docker.example.com:443
     - 配置jenkins，使用engineer365-builder账号创建一个credential

## 重启和升级：
   https://goharbor.io/docs/2.0.0/install-config/reconfigure-manage-lifecycle/)

## 其它
   - 安装目录：/opt/harbor
   - 数据目录：/data/harbor

   