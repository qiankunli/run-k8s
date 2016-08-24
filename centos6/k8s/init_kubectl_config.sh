#!/bin/bash
kubectl config set-cluster default-cluster --server=http://192.168.3.56:8079
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context
