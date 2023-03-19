usefull commands


## minikube

     minikube start -n 3                   # start minikube with 3 nodes
     minikube start --driver virtualbox    # create nodes in virtual box
     minkube ssh -n <nodename>             # log in into <nodename>

## kubectl

     <create command> --dry-run=client -o=yaml   # create yaml output file for command
