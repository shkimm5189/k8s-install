#/bin/bash

# This is k8s control
# insert kubernetes version
# black is latest version
# we are practice version is 1.18.19-00
kube_version="1.19.12-00"
current_ip=`ip a s | grep enp0s8$ | awk '{ split( $2, cur_ip, "/" ); print cur_ip[1] }'`
current_cidr=`echo "${current_ip}" | awk '{ split( $0, cidr, "."); print cidr[1]"."cidr[2]".0.0/16"}'`
# docker install
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# kubeadm install
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
if [ -z ${kube_version} ]; then
        sudo apt-get install -y kubelet kubeadm kubectl
else
        sudo apt-get install -y kubelet="${kube_version}" kubeadm="${kube_version}" kubectl="${kube_version}"
fi

sudo apt-mark hold kubelet kubeadm kubectl
swapoff -a

# Setting k8s
sudo kubeadm init --control-plane-endpoint "${current_ip}" --pod-network-cidr "${current_cidr}" --apiserver-advertise-address "${current_ip}"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

token_val=`kubeadm token list | awk '{print $1}' | sed 1d`
hash_val=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'`
# Setting add-on network calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
sudo kubeadm join --token "${token_val}" "${current_ip}":6443 --discovery-token-ca-cert-hash sha256:"${hash_val}"
