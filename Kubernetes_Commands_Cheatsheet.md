# Kubernetes Commands Cheatsheet

## Quick start

      start docker desktop
      minikube start
      kubectl proxy   # in new tab

[dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/clusterrolebinding?namespace=default)

## Quick stop

     stop kubectl proxy
     minikube stop
     close docker desktop

## Commands

      minikube version
      minikube status
      minikube start
      minikube stop
      minikube addons list
      minikube addons enable metrics-server
      minikube dashboard
      minikube ip
      minikube ssh


      kubectl cluster-info
      kubectl config view
      subl ~/.kube/config
      kubectl get namespaces
      kubectl get replicasets
      kubectl get pods
      kubectl get pods -L k8s-app,label2     # show with 2 label columns mentioned 
      kubectl get pods -l k8s-app=web-dash   # select label content
      kubectl get deployments
      kubectl get services
      kubectl delete deployments web-dash
      kubectl create -f webserver.yaml
      kubectl expose deployment webserver --name=web-service --type=NodePort  # expose a previous deployment
      kubectl describe service web-service
      kubectl get pod my-pod-to-watch -w
      kubectl get all -l app=web-cli
      kubectl logs my-pod-df233... 
      kubectl get configmap
      kubectl get secret
      kubectl get node -o wide
      kubectl exec app-config -- /bin/sh -c ' cat /usr/share/nginx/html/index.html' # run comand in pod container
      kubectl get ingress ingress-demo
      kubectl describe ingress ingress-demo

      


kubctl proxy 

      kubectl proxy    # in terminal tab
      kubectl proxy &  # in background
      jobs             # show jobs in background
      fg               # bring job to forground


Get a bearer token 

      TOKEN=$(kubectl describe secret -n kube-system $(kubectl get secrets -n kube-system | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t' | tr -d " ")

Get the API server endpoint:

      APISERVER=$(kubectl config view | grep https | cut -f 2- -d ":" | tr -d " ")

Access the API server using the curl command, as shown below:

      curl $APISERVER --header "Authorization: Bearer $TOKEN" --insecure

Or using the certificates from `./kube/config`. NOT WORKING, TODO find out how to create accessible certificate. Probably replace 'encoded-cert' en 'encoded-key'.   

      curl $APISERVER --cert encoded-cert --key encoded-key --cacert encoded-ca


## Deployments

Sample deployment yaml file:

            apiVersion: apps/v1
            kind: Deployment
            metadata:
              name: nginx-deployment
              labels:
                app: nginx
            spec:
              replicas: 3
              selector:
                matchLabels:
                  app: nginx
              template:
                metadata:
                  labels:
                    app: nginx
                spec:
                  containers:
                  + name: nginx
                    image: nginx:1.15.11
                    ports:
                    + containerPort: 80
            


creating a deployment from the commandline:

    kubectl create deployment mynginx --image=nginx:1.20.0-alpine
    kubectl get deployments,replicasets,pods -l app=mynginx
    kubectl get deploy,rs,po -l app=mynginx
    kubectl scale deploy mynginx --replicas=3
    kubectl describe deploy mynginx
    kubectl rollout history deploy mynginx
    kubectl rollout history deploy mynginx --revision=1
    kubectl set image deployment mynginx nginx=nginx:1.20.1-alpine
    kubectl set image deployment mynginx nginx=nginx:1.20.2-alpine
    kubectl rollout undo deployment mynginx --to-revision=1
    kubectl rollout undo deployment mynginx --to-revision=2
    kubectl rollout undo deployment mynginx --to-revision=3

Up to 10 revisions stay available (by defaults) for Deployments. But also other controllers (eg DaemonSets and StatefulSets) feature revision too.


## Authentication, Authorization & Admission Control

### Authentication
We have **Normal Users** and **Service Accounts** and different [Authenitication Modules](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authentication-strategies)

- X509 Client Certificates
- Static Token File
- Bootstrap Tokens
- Service Account Tokens
- OpenID Connect Tokens
- Webhook Token Authentication
- Authenticating Proxy

### Authorization
[Start api server](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) with some authorization modules (Example,RBAC) to enable modules

    kube-apiserver --authorization-mode=Example,RBAC --other-options --more-options

Some modules:

- [Node authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/)
- [Attribute-Based Access Control (ABAC)](https://kubernetes.io/docs/reference/access-authn-authz/abac/)
- [Webhook](https://kubernetes.io/docs/reference/access-authn-authz/webhook/)
- [Role-Based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
      + Role
      + ClusterRole
      + RoleBinding
      + ClusterRoleBinding

### Admission Control
[Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) are used to specify granular access control policies, which include allowing privileged containers, checking on resource quota, etc. We force these policies using different admission controllers, like ResourceQuota, DefaultStorageClass, AlwaysPullImages, etc. They come into effect only after API requests are authenticated and authorized.
See the list of [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-does-each-admission-controller-do) 

### Demo

Start with quick start 

    kubectl config view
    kubectl create namespace lfs158
    mkdir rbac
    cd rbac/
    # Create a private key for the student user 
    openssl genrsa -out student.key 2048
    # Create a certificate signing request for the student
    openssl req -new -key student.key -out student.csr -subj "/CN=student/O=learner"

    # Generate var in base65 format 
    tmpStudent=`cat student.csr | base64 | tr -d '\n','%'`

    # use var in creation of certificate signing request yaml file. Note use without spaces before `cat`
    cat << EOF > signing-request.yaml
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
      name: student-csr
    spec:
      groups:
      - system:authenticated
      request: $tmpStudent
      signerName: kubernetes.io/kube-apiserver-client
      usages:
      - digital signature
      - key encipherment
      - client auth
    EOF

    # Create the certificate signing request object, list the certificate signing request objects.
    kubectl create -f signing-request.yaml
    kubectl get csr
    # Approve the certificate signing request object
    kubectl certificate approve student-csr
    # List the certificate signing request objects again. State went Pending --> Approved,Issued
    kubectl get csr

    # Extract the approved certificate from the certificate signing request, decode it with base64 and save it as a certificate file.
    kubectl get csr student-csr -o jsonpath='{.status.certificate}' | base64 --decode > student.crt
    cat student.crt

    # Configure the kubectl client's configuration manifest with the student user's credentials by assigning the key and certificate
    kubectl config set-credentials student --client-certificate=student.crt --client-key=student.key

    # Create a new context entry in the kubectl client's configuration manifest for the student user, associated with the lfs158 namespace in the minikube cluster:
    kubectl config set-context student-context --cluster=minikube --namespace=lfs158 --user=student
    kubectl config view

    # While in the default minikube context, create a new deployment in the lfs158 namespace:
    kubectl -n lfs158 create deployment nginx --image=nginx:alpine

    # From the new context student-context try to list pods. The attempt fails because the student user has no permissions configured for the student-context
    kubectl --context=student-context get pods

    # Create a pod-reader role yaml file 
    cat << EOF > role.yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: pod-reader
      namespace: lfs158
    rules:
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "watch", "list"]
    EOF

    # Create role and list roles
    kubectl create -f role.yaml
    kubectl -n lfs158 get roles


    # Create a pod-reader-access rolebinding file
    cat << EOF > rolebinding.yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: pod-read-access
      namespace: lfs158
    subjects:
    - kind: User
      name: student
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role
      name: pod-reader
      apiGroup: rbac.authorization.k8s.io
    EOF

    # Create rolebinding and list, finaly check of role without errors
    kubectl create -f rolebinding.yaml 
    kubectl -n lfs158 get rolebindings
    kubectl --context=student-context get pods

## ConfigMaps and Secrets

    kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2
    kubectl get configmaps my-config -o yaml

    kubectl create secret generic my-password --from-literal=password=mysqlpassword
    kubectl get secret my-password
    kubectl describe secret my-password

    echo mysqlpassword | base64.                # --> bXlzcWxwYXNzd29yZAo=
    echo -n 'bXlzcWxwYXNzd29yZAo=' > password.txt
    kubectl create secret generic my-file-password --from-file=password.txt
    kubectl get secret my-file-password
    kubectl describe secret my-file-password

## Ingres

Ingress Controllers are also know as Controllers, Ingress Proxy, Service Proxy, Revers Proxy, etc. Sample controllers are Contour, HAProxy Ingress, Istio, Kong, Traefik, etc.

    minikube addons enable ingress 




