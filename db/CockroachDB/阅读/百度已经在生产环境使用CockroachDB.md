

百度已经在生产环境使用CockroachDB 
http://www.infoq.com/cn/news/2017/10/Baidu-CockroachDB-production-env

https://www.cockroachlabs.com/

百度DBA团队在生产环境需要支持十亿用户对应用程序的访问，所以他们必须提供大规模且性能稳定的基础设施。

* MySQL
  * 并通过分片和中间件为关键应用提供支持
  * 有新应用加入时，不仅能够提供大数据量存储，还能保持高并发的实时访问
  * 支持二级索引，同时还能支持基于已有数据执行一些实时的数据分析
  * 改用NoSQL数据库，就要放弃二级索引、聚合功能和事务特性
* CockroachDB
  * 如果要扩展容量，只要加入新的服务器，安装CockroachDB，重新配置负载均衡器
  * 负载均衡器自动对数据库流量进行路由、均衡和复制
  * 可以使用二级索引，还支持分布式SQL查询
* 自动化
  * 数据库复制、均衡管理和失效备援。
