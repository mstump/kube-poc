#!/bin/bash

for SERVICES in docker kube-apiserver kube-controller-manager kube-scheduler flanneld kube-proxy kubelet; do
    systemctl stop $SERVICES
    systemctl start $SERVICES
    systemctl status $SERVICES
done
