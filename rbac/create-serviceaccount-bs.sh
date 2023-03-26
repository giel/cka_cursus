#!/usr/bin/env bash

kubectl create -f create-serviceaccount-bs.yaml
kubectl get serviceaccounts
kubectl apply -f create-serviceaccount-secret.yaml
kubectl get secret/build-robot-secret -o yaml
