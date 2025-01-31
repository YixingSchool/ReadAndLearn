

kubernetes安全控制认证与授权(二) - CSDN博客 
http://blog.csdn.net/yan234280533/article/details/76359199


上文中介绍了kubernetes的认证体系，本文将继续kubernetes授权体系。授权主要是用于对集群资源的访问控制，通过检查请求包含的相关属性值，与相对应的访问策略相比较，API请求必须满足某些策略才能被处理。跟认证类似，Kubernetes也支持多种授权机制，并支持同时开启多个授权插件（只要有一个验证通过即可）。如果授权成功，则用户的请求会发送到准入控制模块做进一步的请求验证；对于授权失败的请求则返回HTTP 403。

Kubernetes授权处理以下的请求属性：

user, group, extra
API、请求方法（如get、post、update、patch和delete）和请求路径（如/api）
请求资源和子资源
Namespace
API Group
目前，Kubernetes支持授权插件：

ABAC
RBAC
Webhook
Node
AlwaysDeny和AlwaysAllow

Kubernetes还支持AlwaysDeny和AlwaysAllow模式，其中AlwaysDeny仅用来测试，而AlwaysAllow则允许所有请求（会覆盖其他模式）。

可以在API Server中通过下面的参数进行配置：

--authorization-mode=AlwaysAllow
--authorization-mode=AlwaysDeny
1
2
ABAC授权

使用ABAC授权需要API Server配置--authorization-policy-file=SOME_FILENAME，文件格式为每行一个json对象，比如

{
    "apiVersion": "abac.authorization.kubernetes.io/v1beta1",
    "kind": "Policy",
    "spec": {
        "group": "system:authenticated",
        "nonResourcePath": "*",
        "readonly": true
    }
}
{
    "apiVersion": "abac.authorization.kubernetes.io/v1beta1",
    "kind": "Policy",
    "spec": {
        "group": "system:unauthenticated",
        "nonResourcePath": "*",
        "readonly": true
    }
}
{
    "apiVersion": "abac.authorization.kubernetes.io/v1beta1",
    "kind": "Policy",
    "spec": {
        "user": "admin",
        "namespace": "*",
        "resource": "*",
        "apiGroup": "*"
    }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
可以在API Server中通过下面的参数进行配置：

--authorization-mode=ABAC
1
RBAC授权

RBAC 的授权策略可以利用 kubectl 或者 Kubernetes API 直接进行配置。RBAC 可以授权给用户，让用户有权进行授权管理，这样就可以无需接触节点，直接进行授权管理。RBAC 在 Kubernetes 中被映射为 API 资源和操作。

因为 Kubernetes 社区的投入和偏好，相对于 ABAC 而言，RBAC 是更好的选择。

RBAC基本概念包括：

role

角色是一系列权限的集合，例如一个角色可以包含读取 Pod 的权限和列出 Pod 的权限， ClusterRole 跟 Role 类似，但是可以在集群中到处使用（ Role 是 namespace 一级的）。

role binding

RoleBinding 把角色映射到用户，从而让这些用户继承角色在 namespace 中的权限。ClusterRoleBinding 让用户继承 ClusterRole 在整个集群中的权限。

另外还要考虑cluster roles和cluster role binding。cluster role和cluster role binding方法跟role和role binding一样，出了它们有更广的scope。详细差别请访问 role binding与clsuter role binding.

可以通过下面参数设置：

--authorization-mode=RBAC
1
WebHook授权

使用WebHook授权需要API Server配置--authorization-webhook-config-file=SOME_FILENAME和--runtime-config=authorization.k8s.io/v1beta1=true，配置文件格式同kubeconfig，如

# clusters refers to the remote service.
clusters:
  - name: name-of-remote-authz-service
    cluster:
      certificate-authority: /path/to/ca.pem      # CA for verifying the remote service.
      server: https://authz.example.com/authorize # URL of remote service to query. Must use 'https'.

# users refers to the API Server's webhook configuration.
users:
  - name: name-of-api-server
    user:
      client-certificate: /path/to/cert.pem # cert for the webhook plugin to use
      client-key: /path/to/key.pem          # key matching the cert

# kubeconfig files require a context. Provide one for the API Server.
current-context: webhook
contexts:
- context:
    cluster: name-of-remote-authz-service
    user: name-of-api-server
  name: webhook
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
API Server请求Webhook server的格式为

{
  "apiVersion": "authorization.k8s.io/v1beta1",
  "kind": "SubjectAccessReview",
  "spec": {
    "resourceAttributes": {
      "namespace": "kittensandponies",
      "verb": "get",
      "group": "unicorn.example.org",
      "resource": "pods"
    },
    "user": "jane",
    "group": [
      "group1",
      "group2"
    ]
  }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
而Webhook server需要返回授权的结果，允许(allowed=true)或拒绝(allowed=false)：

{
  "apiVersion": "authorization.k8s.io/v1beta1",
  "kind": "SubjectAccessReview",
  "status": {
    "allowed": true
  }
}
1
2
3
4
5
6
7
可以在API Server中通过下面的参数进行配置：

--authorization-mode=Webhook
1
Node授权

仅v1.7版本以上支持Node授权，配合NodeRestriction准入控制来限制kubelet仅可访问node、endpoint、pod、service以及secret、configmap、PV和PVC等相关的资源，配置方法为

--authorization-mode=Node,RBAC --admission-control=...,NodeRestriction,...

注意，kubelet认证需要使用system:nodes组，并使用用户名system:node:<nodeName>。

参考链接：

Authorization