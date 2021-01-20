# Store1虚拟机 - MySQL ...

## 日常启动

  执行：`./up.sh`

  验证：使用MySQL client登录http://192.168.50.21:3306
  ```shell
  mysql --user=playground_user --password=playground_password --host 192.168.50.21 -D playground
  mysql> show databases;
  mysql> show tables;
  ```

## 后续设置操作请参照 [../../mysql](../../mysql)

