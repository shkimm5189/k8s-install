#!/bin/bash

cd ~
git clone --single-branch --branch v1.6.7 https://github.com/rook/rook.git

cd rook/cluster/examples/kubernetes/ceph
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
