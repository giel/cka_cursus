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

Rollout a new revision, check status of rollout, check history, check a revision in history in details 

    k set image deployment app-cache memcached=memcached:1.6.10
    k rollout status deployment app-cache
    k rollout history deployment app-cache
    k rollout history deployment app-cache --revision=1

Undo rollout: the last one and a go back to a specific version

    k rollout undo deployment app-cache
    k rollout undo deployment app-cache --to-revision=1

Scaling: to 6 replicas

    k scale deployment app-cache --replicas=6

Statefulsets: create a redis services with statefulset, and scale this

    k create -f redis-services.yaml
    k get statefulset redis
    k scale statefulset redis --replicas=3
    k get pods
    k delete -f redis-services.yaml

Autoscaling

    k create -f app-cache-deployment.yaml
    k autoscale deployment app-cache --cpu-percent=80 --min=3 --max=5
    k get hpa
    k describe hpa app-cache
    k get hpa app-cache -o=yaml > app-cache-autoscaler.yaml


## Links

- [Commands](./Commands.md)
