

# https://feisky.gitbooks.io/kubernetes/apps/linkerd.html

Linkerd

Linkerd是一个面向云原生应用的Service Mesh组件，也是CNCF项目之一。
它为服务间通信提供了一个统一的管理和控制平面，
并且解耦了应用程序代码和通信机制，
从而无需更改应用程序就可以可视化控制服务间的通信
linkerd实例是无状态的，可以以每个应用一个实例(sidecar)或者每台Node一个实例的方式部署。

Linkerd的主要特性包括

服务发现
动态请求路由
HTTP代理集成，支持HTTP、TLS、gRPC、HTTP/2等
感知时延的负载均衡，支持多种负载均衡算法，如Power of Two Choices (P2C) Least Loaded、Power of Two Choices (P2C) peak ewma、Aperture: least loaded、Heap: least loaded、Round robin等
熔断机制，自动移除不健康的后端实例，包括fail fast（只要连接失败就移除实例）和failure accrual（超过5个请求处理失败时才将其标记为失效，并保留一定的恢复时间 ）两种
分布式跟踪和度量
Linkerd原理

Linkerd路由将请求处理分解为多个步骤

(1) IDENTIFICATION：为实际请求设置逻辑名字（即请求的目的服务），如默认将HTTP请求GET http://example/hello赋值名字/svc/example
(2) BINDING：dtabs负责将逻辑名与客户端名字绑定起来，客户端名字总是以/#或/$开头，比如
# 假设dtab为
/env => /#/io.l5d.serversets/discovery
/svc => /env/prod

# 那么服务名/svc/users将会绑定为
/svc/users
/env/prod/users
/#/io.l5d.serversets/discovery/prod/users
(3) RESOLUTION：namer负责解析客户端名，并得到真实的服务地址（IP+端口）
(4) LOAD BALANCING：根据负载均衡算法选择如何发送请求


Linkerd部署

Linkerd以DaemonSet的方式部署在每个Node节点上：

# Deploy linkerd.
# For CNI, deploy linkerd-cni.yml instead.
# kubectl apply -f https://github.com/linkerd/linkerd-examples/raw/master/k8s-daemonset/k8s/linkerd-cni.yml
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd.yml

# Deploy linked-viz.
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-viz/master/k8s/linkerd-viz.yml
默认情况下，Linkerd的Dashboard监听在每个容器实例的9990端口，可以通过服务的相应端口来访问。

INGRESS_LB=$(kubectl get svc l5d -o jsonpath="{.status.loadBalancer.ingress[0].*}")
echo "open http://$INGRESS_LB:9990 in browser"

VIZ_INGRESS_LB=$(kubectl get svc linkerd-viz -o jsonpath="{.status.loadBalancer.ingress[0].*}")
echo "open http://$VIZ_INGRESS_LB in browser"
对于不支持LoadBalancer的集群，可以通过NodePort来访问

HOST_IP=$(kubectl get po -l app=l5d -o jsonpath="{.items[0].status.hostIP}")
echo "open http://$HOST_IP:$(kubectl get svc l5d -o 'jsonpath={.spec.ports[2].nodePort}') in browser"
应用程序在使用Linkerd时需要为应用设置HTTP代理，其中

HTTP使用$(NODE_NAME):4140
HTTP/2使用$(NODE_NAME):4240
gRPC使用$(NODE_NAME):4340
在Kubernetes中，可以使用Downward API来获取NODE_NAME，比如

    env:
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: http_proxy
      value: $(NODE_NAME):4140
开启TLS

kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/certificates.yml
kubectl delete ds/l5d configmap/l5d-config
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-tls.yml
Zipkin

# Deploy zipkin.
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/zipkin.yml

# Deploy linkerd for zipkin.
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-zipkin.yml

# Get zipkin endpoint.
ZIPKIN_LB=$(kubectl get svc zipkin -o jsonpath="{.status.loadBalancer.ingress[0].*}")
echo "open http://$ZIPKIN_LB in browser"


# Ingress Controller
## Linkerd也可以作为Kubernetes Ingress Controller使用，注意下面的步骤将Linkerd部署到了l5d-system namespace。

kubectl create ns l5d-system
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-ingress-controller.yml -n l5d-system

L5D_SVC_IP=$(kubectl get svc l5d -n l5d-system -o jsonpath="{.status.loadBalancer.ingress[0].*}")
echo "open http://$L5D_SVC_IP:9990 in browser"
Linkerd使用示例

接下来部署两个测试服务。

首先验证Kubernetes集群是否支持nodeName，正常情况下node-name-test容器会输出一个nslookup解析后的IP地址：

kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/node-name-test.yml
kubectl logs node-name-test
然后部署hello world示例：

kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world.yml
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/world-v2.yml
通过Linkerd代理访问服务

$ http_proxy=$INGRESS_LB:4140 curl -s http://hello
Hello (10.12.2.5) world (10.12.0.6)!!
如果开启了Linkerd ingress controller，那么可以继续创建Ingress：

kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world-ingress.yml

curl ${L5D_SVC_IP}
curl -H "Host: world.v2" $L5D_SVC_IP


# Conduit
# Conduit 是 Buoyant 公司推出的下一代轻量级 service mesh。
# 与 linkerd 不同的是，它专用于 Kubernetes 集群中，并且比 linkerd 更轻量级
# （基于 Rust 和 Go，没有了 JVM 等大内存的开销），
# 可以以 sidecar 的方式把代理服务跟实际服务的 Pod 运行在一起（这点跟 Istio 类似）。

$ curl https://run.conduit.io/install | bash
..
.
Conduit was successfully installed 🎉

$ conduit install | kubectl apply -f -
..
.
namespace "conduit" created...

$ conduit dashboard
Running `kubectl proxy --port=8001`... |

# Install a demo app
$ curl https://raw.githubusercontent.com/runconduit/conduit-examples/master/emojivoto/emojivoto.yml | conduit inject - --skip-inbound-ports=80 | kubectl apply -f -
参考文档

WHAT’S A SERVICE MESH? AND WHY DO I NEED ONE?
Linkerd官方文档
A SERVICE MESH FOR KUBERNETES
Linkerd examples
Service Mesh Pattern
https://conduit.io