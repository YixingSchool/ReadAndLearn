设置Linux服务器登录密码过期时长 | 易学教程 https://www.e-learn.cn/content/linux/2191826

2.使用命令chage：修改指定用户的登录密码的有效期限
命令语法：

chage [选项] 参数 用户
常用选项说明
-m：密码可更改的最小天数。参数为0代表任何时候都可以更改密码。
-M：密码保持有效的最大天数。参数为99999（5个9）代表一直有效,永不过期。
-l：列出当前的设置。查看指定用户确定用户的密码或帐号何时过期。
3.执行以下命令查看用户（以root为例）的密码有效时长

chage -l root


再执行以下命令修改密码有效时长

chage -m 0 root  # 如果已经是0,就可以不再执行了
chage -M 99999 root  # 修改后密码永不过期
chage -l root  # 查看修改后的结果