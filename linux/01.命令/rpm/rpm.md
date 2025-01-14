
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Linux rpm 命令参数使用详解［介绍和应用］](#linux-rpm-命令参数使用详解介绍和应用)
	* [一、RPM包管理的用途；](#一-rpm包管理的用途)
	* [二、RPM 的使用权限；](#二-rpm-的使用权限)
	* [三、rpm 的一点简单用法；](#三-rpm-的一点简单用法)
		* [一）初始化rpm 数据库；](#一初始化rpm-数据库)
		* [二）RPM软件包管理的查询功能：](#二rpm软件包管理的查询功能)
			* [1、对系统中已安装软件的查询；](#1-对系统中已安装软件的查询)
				* [1）查询系统已安装的软件；](#1查询系统已安装的软件)
				* [2）查询一个已经安装的文件属于哪个软件包；](#2查询一个已经安装的文件属于哪个软件包)
				* [3）查询已安装软件包都安装到何处；](#3查询已安装软件包都安装到何处)
				* [4）查询一个已安装软件包的信息](#4查询一个已安装软件包的信息)
				* [5）查看一下已安装软件的配置文件；](#5查看一下已安装软件的配置文件)
				* [6）查看一个已经安装软件的文档安装位置：](#6查看一个已经安装软件的文档安装位置)
				* [7）查看一下已安装软件所依赖的软件包及文件；](#7查看一下已安装软件所依赖的软件包及文件)
			* [2、对于未安装的软件包的查看：](#2-对于未安装的软件包的查看)
				* [1）查看一个软件包的用途、版本等信息；](#1查看一个软件包的用途-版本等信息)
				* [2）查看一件软件包所包含的文件；](#2查看一件软件包所包含的文件)
				* [3）查看软件包的文档所在的位置；](#3查看软件包的文档所在的位置)
				* [5）查看一个软件包的配置文件；](#5查看一个软件包的配置文件)
				* [4）查看一个软件包的依赖关系](#4查看一个软件包的依赖关系)
		* [三）软件包的安装、升级、删除等；](#三软件包的安装-升级-删除等)
			* [1、安装和升级一个rpm 包；](#1-安装和升级一个rpm-包)
			* [2、删除一个rpm 包；](#2-删除一个rpm-包)
	* [四、导入签名：](#四-导入签名)
	* [五、RPM管理包管理器支持网络安装和查询；](#五-rpm管理包管理器支持网络安装和查询)
	* [六、对已安装软件包查询的一点补充；](#六-对已安装软件包查询的一点补充)
	* [七、从rpm软件包抽取文件；](#七-从rpm软件包抽取文件)
	* [八、RPM的配置文件；](#八-rpm的配置文件)
	* [九、src.rpm的用法：](#九-srcrpm的用法)

<!-- /code_chunk_output -->
---

# Linux rpm 命令参数使用详解［介绍和应用］

* [Linux rpm 命令参数使用详解［介绍和应用］ - 小炒花生米 - 博客园 ](http://www.cnblogs.com/xiaochaohuashengmi/archive/2011/10/08/2203153.html)

RPM是RedHat Package Manager（RedHat软件包管理工具）类似Windows里面的“添加/删除程序”

rpm 执行安装包
二进制包（Binary）以及源代码包（Source）两种。二进制包可以直接安装在计算机中，而源代码包将会由RPM自动编译、安装。源代码包经常以src.rpm作为后缀名。

常用命令组合：

 
```sh
－ivh：安装显示安装进度--install--verbose--hash
－Uvh：升级软件包--Update；
－qpl：列出RPM软件包内的文件信息[Query Package list]；
－qpi：列出RPM软件包的描述信息[Query Package install package(s)]；
－qf：查找指定文件属于哪个RPM软件包[Query File]；
－Va：校验所有的RPM软件包，查找丢失的文件[View Lost]；
－e：删除包
```

 

```
rpm -q samba //查询程序是否安装

rpm -ivh  /media/cdrom/RedHat/RPMS/samba-3.0.10-1.4E.i386.rpm //按路径安装并显示进度
rpm -ivh --relocate /=/opt/gaim gaim-1.3.0-1.fc4.i386.rpm    //指定安装目录

rpm -ivh --test gaim-1.3.0-1.fc4.i386.rpm　　　 //用来检查依赖关系；并不是真正的安装；
rpm -Uvh --oldpackage gaim-1.3.0-1.fc4.i386.rpm //新版本降级为旧版本

rpm -qa | grep httpd　　　　　 ＃[搜索指定rpm包是否安装]--all搜索*httpd*
rpm -ql httpd　　　　　　　　　＃[搜索rpm包]--list所有文件安装目录

rpm -qpi Linux-1.4-6.i368.rpm　＃[查看rpm包]--query--package--install package信息
rpm -qpf Linux-1.4-6.i368.rpm　＃[查看rpm包]--file
rpm -qpR file.rpm　　　　　　　＃[查看包]依赖关系
rpm2cpio file.rpm |cpio -div    ＃[抽出文件]

rpm -ivh file.rpm 　＃[安装新的rpm]--install--verbose--hash
rpm -ivh

rpm -Uvh file.rpm    ＃[升级一个rpm]--upgrade
rpm -e file.rpm      ＃[删除一个rpm包]--erase
```
常用参数：

Install/Upgrade/Erase options:

```sh
-i, --install                     install package(s)
-v, --verbose                     provide more detailed output
-h, --hash                        print hash marks as package installs (good with -v)
-e, --erase                       erase (uninstall) package
-U, --upgrade=<packagefile>+      upgrade package(s)
－-replacepkge                    无论软件包是否已被安装，都强行安装软件包
--test                            安装测试，并不实际安装
--nodeps                          忽略软件包的依赖关系强行安装
--force                           忽略软件包及文件的冲突

Query options (with -q or --query):
-a, --all                         query/verify all packages
-p, --package                     query/verify a package file
-l, --list                        list files in package
-d, --docfiles                    list all documentation files
-f, --file                        query/verify package(s) owning file
```
RPM源代码包装安装

.src.rpm结尾的文件，这些文件是由软件的源代码包装而成的，用户要安装这类RPM软件包，必须使用命令：

 

rpm　--recompile　vim-4.6-4.src.rpm   ＃这个命令会把源代码解包并编译、安装它，如果用户使用命令：

rpm　--rebuild　vim-4.6-4.src.rpm　　＃在安装完成后，还会把编译生成的可执行文件重新包装成i386.rpm的RPM软件包。
 

偶不喜欢写比较复杂的东东，麻烦的话`不过做为参考`偶还素转了一位哒人的`写的真很全面`


作者：北南南北
来自：LinuxSir.Org
提要：RPM 是 Red Hat Package Manager 的缩写，原意是Red Hat 软件包管理；本文介绍RPM，并结合实例来解说RPM手工安装、查询等应用；


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
正文：
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

RPM 是 Red Hat Package Manager 的缩写，本意是Red Hat 软件包管理，顾名思义是Red Hat 贡献出来的软件包管理；在Fedora 、Redhat、Mandriva、SuSE、YellowDog等主流发行版本，以及在这些版本基础上二次开发出来的发行版采用；

RPM包里面都包含什么？里面包含可执行的二进制程序，这个程序和Windows的软件包中的.exe文件类似是可执行的；RPM包中还包括程序运行时所需要的文件，这也和Windows的软件包类似，Windows的程序的运行，除了.exe文件以外，也有其它的文件；

一个RPM 包中的应用程序，有时除了自身所带的附加文件保证其正常以外，还需要其它特定版本文件，这就是软件包的依赖关系；依赖关系并不是Linux特有的， Windows操作系统中也是同样存在的；比如我们在Windows系统中运行3D游戏，在安装的时候，他可能会提示，要安装Direct 9 ；Linux和Windows原理是差不多的；

软件安装流程图：

 


本文使用范围：

1、本文是对RPM管理的软件的说明，对通过file.tar.gz 或file.tar.bz2源码包用 make ;make install 安装的软件无效；
2、安装软件时，最好用各自发行版所提供的系统软件包管理工具，对于Fedora/Redhat 您可以参考如下文章；

1）Fedora 系统管理软件包工具 system-config-packages，方便的添加和移除系统安装盘提供的软件包，详情请看 《Fedora 软件包管理器system-config-packages》

2）Redhat 系统管理软件包工具,新一点的系统应该是 redhat-config-packages ，用法和 《Fedora 软件包管理器system-config-packages》 一样；

3）apt + synaptic 软件包在线安装、移除、升级工具； 用法：《用apt+synaptic 在线安装或升级Fedora core 4.0 软件包》
4）yum 软件包在线安装、升级、移除工具；用法：《Fedora/Redhat 在线安装更新软件包，yum 篇》

5）所有的yum和apt 教程 《apt and yum》

目前 apt和yum 已经极为成熟了，建议我们安装软件时，采用 apt或者yum ；如果安装系统盘提供的软件包，可以用 system-config-packages 或redhat-config-packages ；


## 一、RPM包管理的用途；

1、可以安装、删除、升级和管理软件；当然也支持在线安装和升级软件；
2、通过RPM包管理能知道软件包包含哪些文件，也能知道系统中的某个文件属于哪个软件包；
3、可以在查询系统中的软件包是否安装以及其版本；
4、作为开发者可以把自己的程序打包为RPM 包发布；
5、软件包签名GPG和MD5的导入、验证和签名发布
6、依赖性的检查，查看是否有软件包由于不兼容而扰乱了系统；


## 二、RPM 的使用权限；

RPM软件的安装、删除、更新只有root权限才能使用；对于查询功能任何用户都可以操作；如果普通用户拥有安装目录的权限，也可以进行安装；


## 三、rpm 的一点简单用法；

我们除了软件包管理器以外，还能通过rpm 命令来安装；是不是所有的软件包都能通过rpm 命令来安装呢？不是的，文件以.rpm 后缀结尾的才行；有时我们在一些网站上找到file.rpm ，都要用 rpm 来安装；

### 一）初始化rpm 数据库；

通过rpm 命令查询一个rpm 包是否安装了，也是要通过rpm 数据库来完成的；所以我们要经常用下面的两个命令来初始化rpm 数据库；

[root@localhost beinan]# rpm --initdb
[root@localhost beinan]# rpm --rebuilddb 注：这个要花好长时间；
注：这两个参数是极为有用，有时rpm 系统出了问题，不能安装和查询，大多是这里出了问题；

### 二）RPM软件包管理的查询功能：

命令格式

rpm {-q|--query} [select-options] [query-options]
RPM的查询功能是极为强大，是极为重要的功能之一；举几个常用的例子，更为详细的具体的，请参考#man rpm

#### 1、对系统中已安装软件的查询；

##### 1）查询系统已安装的软件；

 

语法：rpm -q 软件名
举例：

 

[root@localhost beinan]# rpm -q gaim
gaim-1.3.0-1.fc4
-q就是 --query ，中文意思是“问”，此命令表示的是，是不是系统安装了gaim ；如果已安装会有信息输出；如果没有安装，会输出gaim 没有安装的信息；

查看系统中所有已经安装的包，要加 -a 参数 ；

[root@localhost RPMS]# rpm -qa

如果分页查看，再加一个管道 |和more命令；
[root@localhost RPMS]# rpm -qa |more
在所有已经安装的软件包中查找某个软件，比如说 gaim ；可以用 grep 抽取出来；

 

[root@localhost RPMS]# rpm -qa |grep gaim
上面这条的功能和 rpm -q gaim 输出的结果是一样的；

##### 2）查询一个已经安装的文件属于哪个软件包；

 

语法 rpm -qf 文件名

注：文件名所在的绝对路径要指出
 

举例：

[root@localhost RPMS]# rpm -qf /usr/lib/libacl.la
libacl-devel-2.2.23-8
##### 3）查询已安装软件包都安装到何处；

语法：rpm -ql 软件名 或 rpm rpmquery -ql 软件名
举例：

[root@localhost RPMS]# rpm -ql lynx
[root@localhost RPMS]# rpmquery -ql lynx
##### 4）查询一个已安装软件包的信息

语法格式： rpm -qi 软件名
举例：

[root@localhost RPMS]# rpm -qi lynx
##### 5）查看一下已安装软件的配置文件；

 

语法格式：rpm -qc 软件名
举例：

[root@localhost RPMS]# rpm -qc lynx
##### 6）查看一个已经安装软件的文档安装位置：

 

语法格式： rpm -qd 软件名
举例：

 

[root@localhost RPMS]# rpm -qd lynx
##### 7）查看一下已安装软件所依赖的软件包及文件；

 

语法格式： rpm -qR 软件名
举例：

[root@localhost beinan]# rpm -qR rpm-python
查询已安装软件的总结：对于一个软件包已经安装，我们可以把一系列的参数组合起来用；比如 rpm -qil ；比如：

[root@localhost RPMS]# rpm -qil lynx

#### 2、对于未安装的软件包的查看：

查看的前提是您有一个.rpm 的文件，也就是说对既有软件file.rpm的查看等；

##### 1）查看一个软件包的用途、版本等信息；

 

语法： rpm -qpi file.rpm
举例：

 

[root@localhost RPMS]# rpm -qpi lynx-2.8.5-23.i386.rpm
##### 2）查看一件软件包所包含的文件；

 

语法： rpm -qpl file.rpm
举例：

[root@localhost RPMS]# rpm -qpl lynx-2.8.5-23.i386.rpm
##### 3）查看软件包的文档所在的位置；

 

语法： rpm -qpd file.rpm
举例：

[root@localhost RPMS]# rpm -qpd lynx-2.8.5-23.i386.rpm
##### 5）查看一个软件包的配置文件；

语法： rpm -qpc file.rpm
举例：

[root@localhost RPMS]# rpm -qpc lynx-2.8.5-23.i386.rpm
##### 4）查看一个软件包的依赖关系

 

语法： rpm -qpR file.rpm
举例：

[root@localhost archives]# rpm -qpR yumex_0.42-3.0.fc4_noarch.rpm
/bin/bash
/usr/bin/python
config(yumex) = 0.42-3.0.fc4
pygtk2
pygtk2-libglade
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
usermode
yum >= 2.3.2

### 三）软件包的安装、升级、删除等；


#### 1、安装和升级一个rpm 包；

[root@localhost beinan]#rpm -vih file.rpm 注：这个是用来安装一个新的rpm 包；
[root@localhost beinan]#rpm -Uvh file.rpm 注：这是用来升级一个rpm 包；
如果有依赖关系的，请解决依赖关系，其实软件包管理器能很好的解决依赖关系，请看前面的软件包管理器的介绍；如果您在软件包管理器中也找不到依赖关系的包；那只能通过编译他所依赖的包来解决依赖关系，或者强制安装；

语法结构：

[root@localhost beinan]# rpm -ivh file.rpm --nodeps --force
[root@localhost beinan]# rpm -Uvh file.rpm --nodeps --force
更多的参数，请查看 man rpm

举例应用：

[root@localhost RPMS]# rpm -ivh lynx-2.8.5-23.i386.rpm
Preparing... ########################################### [100%]
      1:lynx ########################################### [100%]
[root@localhost RPMS]# rpm -ivh --replacepkgs lynx-2.8.5-23.i386.rpm
Preparing... ########################################### [100%]
      1:lynx ########################################### [100%]
注： --replacepkgs 参数是以已安装的软件再安装一次；有时没有太大的必要；

测试安装参数 --test ，用来检查依赖关系；并不是真正的安装；

[root@localhost RPMS]# rpm -ivh --test gaim-1.3.0-1.fc4.i386.rpm
Preparing... ########################################### [100%]
由新版本降级为旧版本，要加 --oldpackage 参数；

 

[root@localhost RPMS]# rpm -qa gaim
gaim-1.5.0-1.fc4
[root@localhost RPMS]# rpm -Uvh --oldpackage gaim-1.3.0-1.fc4.i386.rpm
Preparing... ########################################### [100%]
      1:gaim ########################################### [100%]
[root@localhost RPMS]# rpm -qa gaim
gaim-1.3.0-1.fc4
为软件包指定安装目录：要加 -relocate 参数；下面的举例是把gaim-1.3.0-1.fc4.i386.rpm指定安装在 /opt/gaim 目录中；

 

[root@localhost RPMS]# rpm -ivh --relocate /=/opt/gaim gaim-1.3.0-1.fc4.i386.rpm
Preparing... ########################################### [100%]
      1:gaim ########################################### [100%]
[root@localhost RPMS]# ls /opt/
gaim
为软件包指定安装目录：要加 -relocate 参数；下面的举例是把lynx-2.8.5-23.i386.rpm 指定安装在 /opt/lynx 目录中；


[root@localhost RPMS]# rpm -ivh --relocate /=/opt/lynx --badreloc lynx-2.8.5-23.i386.rpm
Preparing... ########################################### [100%]
1:lynx ########################################### [100%]

我们安装在指定目录中的程序如何调用呢？一般执行程序，都放在安装目录的bin或者sbin目录中；看下面的例子；如果有错误输出，就做相应的链接，用 ln -s ；

 

[root@localhost RPMS]# /opt/lynx/usr/bin/lynx
Configuration file /etc/lynx.cfg is not available.
[root@localhost RPMS]# ln -s /opt/lynx/etc/lynx.cfg /etc/lynx.cfg
[root@localhost RPMS]# /opt/lynx/usr/bin/lynx www.linuxsir.org

#### 2、删除一个rpm 包；

首先您要学会查询rpm 包 ；请看前面的说明；

[root@localhost beinan]#rpm -e 软件包名

举例：我想移除lynx 包，完整的操作应该是：

[root@localhost RPMS]# rpm -e lynx
如果有依赖关系，您也可以用--nodeps 忽略依赖的检查来删除。但尽可能不要这么做，最好用软件包管理器 systerm-config-packages 来删除或者添加软件；

 

[root@localhost beinan]# rpm -e lynx --nodeps

## 四、导入签名：

[root@localhost RPMS]# rpm --import 签名文件

举例：

 

[root@localhost fc40]# rpm --import RPM-GPG-KEY
[root@localhost fc40]# rpm --import RPM-GPG-KEY-fedora
关于RPM的签名功能，详情请参见 man rpm

## 五、RPM管理包管理器支持网络安装和查询；

比如我们想通过 Fedora Core 4.0 的一个镜像查询、安装软件包；

地址：
http://mirrors.kernel.org/fedora/core/4/i386/os/Fedora/RPMS/

举例：

命令格式：

 

rpm 参数 rpm包文件的http或者ftp的地址
```sh
# rpm -qpi http://mirrors.kernel.org/fedora/core/4/i386/os/ Fedora/RPMS/gaim-1.3.0-1.fc4.i386.rpm
# rpm -ivh http://mirrors.kernel.org/fedora/core/4/i386/os/ Fedora/RPMS/gaim-1.3.0-1.fc4.i386.rpm
```
举一反三吧；


## 六、对已安装软件包查询的一点补充；


[root@localhost RPMS]# updatedb
[root@localhost RPMS]# locate 软件名或文件名
通过updatedb，我们可以用 locate 来查询一些软件安装到哪里了；系统初次安装时要执行updatedb ，每隔一段时间也要执行一次；以保持已安装软件库最新；updatedb 是slocate软件包所有；如果您没有这个命令，就得安装slocate ；

举例：

 

[root@localhost RPMS]# locate gaim


## 七、从rpm软件包抽取文件；

命令格式： rpm2cpio file.rpm |cpio -div

举例：
[root@localhost RPMS]# rpm2cpio gaim-1.3.0-1.fc4.i386.rpm |cpio -div
抽取出来的文件就在当用操作目录中的 usr 和etc中；

其实这样抽到文件不如指定安装目录来安装软件来的方便；也一样可以抽出文件；

为软件包指定安装目录：要加 -relocate 参数；下面的举例是把gaim-1.3.0-1.fc4.i386.rpm指定安装在 /opt/gaim 目录中；

 

[root@localhost RPMS]# rpm -ivh --relocate /=/opt/gaim gaim-1.3.0-1.fc4.i386.rpm
Preparing... ########################################### [100%]
      1:gaim ########################################### [100%]
[root@localhost RPMS]# ls /opt/
gaim
这样也能一目了然；gaim的所有文件都是安装在 /opt/gaim 中，我们只是把gaim 目录备份一下，然后卸掉gaim；这样其实也算提取文件的一点用法；


## 八、RPM的配置文件；

RPM包管理，的配置文件是 rpmrc ，我们可以在自己的系统中找到；比如Fedora Core 4.0中的rpmrc 文件位于；

[root@localhost RPMS]# locate rpmrc
/usr/lib/rpm/rpmrc
/usr/lib/rpm/redhat/rpmrc
我们可以通过 rpm --showrc 查看；具体的还得我们自己来学习。呵。。。不要问我，我也不懂；只要您看了这篇文章，认为对您有用，您的水平就和我差不多；咱们水平是一样的，所以我不能帮助您了；请理解；

## 九、src.rpm的用法：

《file.src.rpm 使用方法的简介》


后记：Fedora/Redhat 入门教程中的软件包管理篇，我已经写了很多了；目前还缺少通过源码包安装软件我方法以及一篇总结性的文档；我想在最近两天补齐，这两篇我以前写过；重新整理一下贴出来就行了；

以我的水平来看，写Fedora 入门教程是极为费力气的，只能一点一点的完善和补充；我所写的教程是面对的是对Linux一无所知新手；教程中实例应用占大部份；我发现没有实例的情况下，新手不如看man ；能看man了，当然也不是什么新手；

经常在论坛上看一些弟兄的提问，虽然一问话解说过去也能应付；但想让大家更方便一点，不如写系统入门教程；虽然所花的时间要长一点；