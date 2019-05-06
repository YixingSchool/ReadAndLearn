

# [一个强大的linux命令——find之exec - CSDN博客 ]
# http://blog.csdn.net/u014762921/article/details/54287302
# 实例1：ls -l命令放在find命令的-exec选项中
find . -type f -exec ls -l {} \; 
# 实例2：在目录中查找更改时间在n日以前的文件并删除它们
find . -type f -mtime +14 -exec rm {} \; 
# +n for greater than n (大于n) 
# -n for less than n(小于n)
find . -type f -mmin -30 -print
# 实例3：在目录中查找更改时间在n日以前的文件并删除它们，在删除之前先给出提示
find . -name "*.log" -mtime +5 -ok rm {} \; 
# 实例4：-exec中使用grep命令
find /etc -name "passwd*" -exec grep "root" {} \; 
# 实例5：查找文件移动到指定目录
find . -name "*.log" -exec mv {} .. \; 
# 实例6：用exec选项执行cp命令
find . -name "*.log" -exec cp {} test3 \; 