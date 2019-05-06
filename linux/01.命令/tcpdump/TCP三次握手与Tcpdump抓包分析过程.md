

* [TCP三次握手与Tcpdump抓包分析过程 - fonxian - 博客园 ](http://www.cnblogs.com/fonxian/p/6565209.html)

# 一、TCP连接建立（三次握手）

过程
客户端A，服务器B，初始序号seq，确认号ack
初始状态：B处于监听状态，A处于打开状态
A -> B : seq = x （A向B发送连接请求报文段，A进入同步发送状态SYN-SENT）
B -> A : ack = x + 1,seq = y （B收到报文段，向A发送确认，B进入同步收到状态SYN-RCVD）
A -> B : ack = y+1 （A收到B的确认后，再次确认，A进入连接状态ESTABLISHED）

连接后的状态：B收到A的确认后，进入连接状态ESTABLISHED

为什么要握手要三次

防止失效的连接请求突然传到服务器端，让服务器端误认为要建立连接。

# 二、TCP连接释放（四次挥手）

过程

A -> B : seq = u （A发出连接释放报文段，进入终止等待1状态FIN-WAIT-1）
B -> A : ack = u + 1,seq = v （B收到报文段，发出确认，TCP处于半关闭，B还可向A发数据，B进入关闭等待状态WAIT）
B -> A : ack = u + 1,seq = w （B重复发送确认号，进入最后确认状态LAST-ACK）
A -> B : ack = w + 1,seq = u + 1 （A发出确认，进入时间等待状态TIME-WAIT）

经过时间等待计时器设置的时间2MSL后，A才进入CLOSED状态

为什么A进入TIME-WAIT后必须等待2MSL

保证A发送的最后一个ACK报文段能达到B
防止失效的报文段出现在连接中

# 三、Tcpdump使用

tcpdump是对网络上的数据包进行截获的包分析工具，它支持针对网络层、协议、主机、网络或端口的过滤，并提供and、or、not等逻辑语句来去掉无用的信息。

监视指定主机的数据包

tcpdump host <IP地址>：截获该IP的主机收到的和发出的所有的数据包
tcpdump host <IP地址> and <IP地址>：截获两个IP对应主机之间的通信

监视指定端口的数据包

tcpdump port <端口号>：截获本机80端口的数据包