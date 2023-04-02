## Deployments

`k = kubectl` in the examples below.

Create a yaml file to with the deployment

    k create deployment app-cache --image=memcached:1.6.8 --replicas=3 \
    --dry-run=client -o=yaml > app-cache-deployment.yaml

Create the deployment with this file

    k create -f app-cache-deployment.yaml

Show the deploymen, pods where it runs, and replicasets

    k get deployments.apps,pods,replicasets.apps
    
Delete the deployment with this file

    k delete -f app-cache-deployment.yaml

## Links

- [Commands](./Commands.md)
