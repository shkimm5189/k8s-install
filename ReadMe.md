# Kubenetes Setting
```bash
cd ~
git clone https://github.com/shkimm5189/k8s-install.git
```


## 1. Vagrant Setting
```
```
## 2. k8s Cluster Setting
- 1 - contol plane 3 - worker node를 구성한다.
#### 2.1 설치에 사용할 패키지
모든 VM에 아래의 패키지들을 설치할 것.
```
- kubeadm: 클러스터를 부트스트랩하는 명령이다.

- kubelet: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트이다.

- kubectl: 클러스터와 통신하기 위한 커맨드 라인 유틸리티이다.
```
* 자세한 명령어 및 설치 과정은 shell script 참고 할것
<br>

install version = 1.18.19
```
원하는 설치 버전은 스크립트 파일안의 변수를 변경하길 바람.
```

- control plane에서 실행 시켜야함.
  ``sh ~/k8s-install/control.sh``
- worker node에서 실행 시켜야함
  ``sh ~/k8s-install/node.sh``

```bash
# 컨트롤의 토큰, ip, hash 값을 넣어서 join을 시켜주어야한다.  
sudo kubeadm join --token {control token} {control s IP}:6443 --discovery-token-ca-cert-hash sha256:{control hash}
```



#### 2.2 k8s version update
##### 2.2.1 업데이트 전에..
- 버전 업그레이드는 한번에 1 단계 상위의 마이너 버전을 업그레이드 해야한다.
``1.17.x -> 1.18.x -> 1.19.x``

- 작업절차
  1. 기본 control plane 노드를 업그레이드
  2. (추가 control plane 노드 업그레이드)
  3. worker node 업그레이드

- 추가 사항
  - 스왑 비활성화 (swap off)
  - 중요한 컴포넌트는 반드시 백업할 것.
  - 컨테이너 해시값이 바뀌므로 업그레이드 후 모든 컨테이너가 재시작됨.

##### 2.2.2 Update

update version = 1.19.12 <br>
```
업데이트를 원하는 버전은 스크립트 안에 update 변수를 변경하길 바람.  
```
[k8s-control]() <br>
``sh ~/k8s-install/update/control-update.sh``

[k8s-workNode]() <br>

``sh ~/k8s-install/update/worker-node-update.sh``


# Add-on Setting
## 1. Metal-LB
[공식 사이트 - metallb](https://metallb.universe.tf/)

### 개요
- opensource이다.
- GCP,Azure,AWS을 사용하지 않고 클러스터 구성시, LB는 계속 'pending'에 머문다.
#### 설치
1. Manifest를 통한 설치
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
```

2. metallb-config.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.200.200-192.168.200.210
```
## 2. Ingress
```
```
## 3. rook
#### 개요
- 노드들에 파일시스템이 비어있는 스토리지가 있어야한다.
- 최소 워커 노드3개가 있어야한다.
```
rook-ceph-storage/cephstorage.sh

쉘스크립트를 실행 시키면된다.
```

## 4. metrics-server
#### 개요
- ``kubectl top nodes``로 클러스터 노드의 사용중인 리소스를 확인 할수있지만 기본적으로 Metric API가 없기 때문에 추가해줘야함.
- [metrics-server github](https://github.com/kubernetes-sigs/metrics-server)
```
k8s 버전과 맞는 버전을 설치 하도록한다.  
```
- deployment.spec.template.spec.containers.arg리스트에 ``--kubectl-insecure-tls`` 를 추가 해주어야 정상작동한다.
