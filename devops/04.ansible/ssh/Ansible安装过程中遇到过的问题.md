

* [Ansible安装过程中遇到过的问题 - CSDN博客 ](http://blog.csdn.net/longxibendi/article/details/46989735)

ansible 需要用到sshpass，密码也是明文保存，
yum -y install ansible
# 1、出现Error: ansible requires a json module, none found!
SSH password:
192.168.24.15 | FAILED >> {
   "failed": true,
   "msg": "Error: ansible requires a json module, nonefound!",
   "parsed": false
}
解决：python版本过低，要不升级python要不就安装python-simplejson

# 2、安装完成后连接客户端服务器报错：
FAILED => Using a SSH password insteadof a key is not possible because Host Key checking is enabled and sshpass doesnot support this.  Please add this host'sfingerprint to your known_hosts file to manage this host.
解决：在ansible 服务器上使用ssh 登陆下/etc/ansible/hosts 里面配置的服务器。然后再次使用ansible 去管理就不会报上面的错误了！但这样大批量登陆就麻烦来。因为默认ansible是使用key验证的，如果使用密码登陆的服务器，使用ansible的话，要不修改ansible.cfg配置文件的ask_pass = True给取消注释，要不就在运行命令时候加上-k，这个意思是-k, --ask-pass ask for SSH password。再修改：host_key_checking= False即可

# 3、如果客户端不在know_hosts里将会报错
paramiko: The authenticity of host '192.168.24.15'can't be established.
The ssh-rsa key fingerprint is397c139fd4b0d763fcffaee346a4bf6b.
Are you sure you want to continueconnecting (yes/no)?
解决：需要修改ansible.cfg的#host_key_checking= False取消注释

# 4、出现FAILED => FAILED: not a valid DSA private key file
解决：需要你在最后添加参数-k

# 5、openssh升级后无法登录报错
PAM unable todlopen(/lib64/security/pam_stack.so): /lib64/security/pam_stack.so: cannot openshared object
file: No such file or directory
解决：sshrpm 升级后会修改/etc/pam.d/sshd 文件。需要升级前备份此文件最后还原即可登录。

# 6、pip安装完成后，运行ansible报错：
File "/usr/lib64/python2.6/subprocess.py",line 642, in __init__ errread, errwrite)
解决：安装：yum installopenssh-clients

# 7、第一次系统初始化运行生成本机ansible用户key时报错
failed: [127.0.0.1] =>{"checksum": "f5f2f20fc0774be961fffb951a50023e31abe920","failed": true}
msg: Aborting, target uses selinux but pythonbindings (libselinux-python) aren't installed!
FATAL: all hosts have already failed –aborting
解决：# yuminstall libselinux-python -y
注意这个是在 host机器上安装，不是在ansible控制机器上。