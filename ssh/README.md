key生成命令：

``` 
ssh-keygen -t rsa -C "$your_email"
```

用户目录下，.ssh文件夹权限为700：

``` shell
drwx------    7 xing  staff     238 Dec  9 23:01 .ssh
```

.ssh下面各个文件权限：

``` shell
-rw-------  1 xing  staff     0B Nov 10 10:55 authorized_keys
-rw-r--r--  1 xing  staff   1.7K Dec  9 23:01 config
-rw-------  1 xing  staff   1.6K Dec 11  2014 id_rsa
-rw-r--r--  1 xing  staff   406B Dec 11  2014 id_rsa.pub
-rw-r--r--  1 xing  staff   7.9K Nov 12 20:55 known_hosts
```

config文件配置模板：

``` shell
Host build
	HostName 192.168.0.2
    User xing
    Port 22222
```

