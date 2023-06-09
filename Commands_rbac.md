# usefull commands

`k = kubectl` in the examples below.

## RBAC


#### serviceaccounts examples

     k create servicaccount build-svc     
     k get serviceaccounts
     k describe serviceaccounts
     k get secrets

using the service account

     k run build-observer --image=alpine --restart=Never \
     --serviceaccount=build-svc

command above does not work in k8s version: v1.26.1. Is below the replacement?

     k run build-observer --image=alpine --restart=Never \
     --as=build-svc

#### roles examples

     k create role read-only --verb=list,get,watch \
     --resource=pods,deployments,serviceaccount
     k get roles
     k describe role read-only

#### rolebindings examples

     k create rolebinding read-only-binding --role=read-only --user=johndoe
     k get rolebindings
     k describe rolebinding read-only-binding

#### checking

     k auth can-i -h
     k auth can-i create deployments --as johndoe

## Links

- [Commands](./Commands.md)
