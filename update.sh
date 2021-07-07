#!/bin/bash
# Insert want to update version
update_ver="1.19.12-00"


swapoff -a
# update kubeadm
sudo apt-mark unhold kubeadm && sudo apt update && apt install -y kubeadm="${update_ver}" &&sudo apt-mark hold kubeadm 


# update kubelet kubectl 
sudo kubeadm upgrade apply v"${update_ver}"
sudo apt-mark unhold kubelet kubectl && sudo apt update && sudo apt install -y kubelet="${update_ver}" kubectl="${update_ver}" && sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet
