# usefull commands

`k = kubectl` in the examples below.

## minikube

     minikube start -n 3                   # start minikube with 3 nodes
     minikube start --driver virtualbox    # create nodes in virtual box
     minkube ssh -n <nodename>             # log in into <nodename>


## kubectl

    k <create command> --dry-run=client -o=yaml   # create yaml output file for command

## namespaces

    k get namespaces

switch namespace

    k config set-context --current --namespace=<insert-namespace-name-here>

## RBAC

see [commands_rbac](./commands_rbac)


## Deployments

see [commands_deployments](./commands_deployments)
