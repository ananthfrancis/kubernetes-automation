

# Kubernetes HA Setup
  
> Setup HA Proxy
  
  1)Login the server where you are going run haproxy.
  2) Execute below commands
      apt-get update
      apt-get install haproxy
  3) Copy the HA_PROXY_Config file content into /etc/haproxy/haproxy.cfg file.
      systemctl restart haproxy

> Common Steps for Master and Worker node

   Install Docker using below command:
      curl https://get.docker.com | sh -

   Installing kubeadm, kublet, and kubectl:
   1) curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
   2) vim /etc/apt/sources.list.d/kubernetes.list
      echo "deb http://apt.kubernetes.io kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
   3) apt-get update
   4) apt-get install kubelet kubeadm kubectl
   5) Disable the swap using below command.
      swapoff -a

> Master Node Setup
   1) Copy the kubeadm-config.yaml file into one of the master node.
   2) Run the below command to initialise the kubernetes cluster.
      kubeadm init --config=kubeadm-config.yaml --upload-certs
   3) To start using your cluster, you need to run the following as a regular user:
      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config
   4) Run the below command to deploy a pod network to the cluster as a regular user(Dont use root to run this command). In         our case, we are going to deploy flannel.
      sysctl net.bridge.bridge-nf-call-iptables=1
      kubectl apply -f                  https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml    
   5) Copy the control plan join command from the init command's result and run it in the another master node which you want         to join.
      kubeadm join 35.247.173.250:6443 --token pzt5xl.z7bm68alodd74wr3 \
    --discovery-token-ca-cert-hash sha256:c17eaac671c571bc40d56a4a255efd3494e523861cbdd1fa1fb1f44dcfa2237e \
    --experimental-control-plane --certificate-key 7303ec096e8dc75b1a0ab69d4ef168bfda8ddaf31e2fde89a55f5fab2cea1e8a

> Worker Node Setup
   1) Copy the worker node join command from the init command's result and run it in the worker node which you want to join.
      kubeadm join 35.247.173.250:6443 --token pzt5xl.z7bm68alodd74wr3 \
      --discovery-token-ca-cert-hash sha256:c17eaac671c571bc40d56a4a255efd3494e523861cbdd1fa1fb1f44dcfa2237e
    
# Setup Jenkins and CICD Pipeline

> Jenkins installation

  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  echo "deb https://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list
  apt-get update
  apt-get install default-jdk
  apt-get install jenkins

  Copy ~/.kube directory from kubernetes cluster to Jenkins server and copy it under jenkins home directory.
  Make sure that jenkins userid has permission to that file.

> Jenkins Job Creation

  1) Create pipeline job in jenkins and use the Jenkins/Jenkinsfile in this repo.

# Create NameSpace

> Development Namespace

  Create development name space using below command.
  kubectl create ns development

# Setup Helm

> Install Helm

  Execute below commands to install helm.

  wget https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
  tar -xvf helm-v2.14.1-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm

> Install tiller

  1) Execute below command to create service account and cluster rolebinding

    kubectl create -f rbac-config.yaml
    
  2) Execute below command to install tiller.
  
    helm init --service-account tiller --history-max 200

  3) Execute below command to check the tiller pod created in kube-system
  
    kubectl get pods --namespace kube-system

# Monitoring 

> Prometheus

  Create monitoring namespace
  
    kubectl create ns monitoring

  Create prometheus cluster role which will allow you to scrape.
  
    kubectl apply -f prometheus_cluster_role.yaml

  Create prometheus configmap which will contains prometheus configuration.
  
    kubectl apply -f prometheus_cm.yaml

  Create prometheus deployment and service using below command.
  
    kubectl apply -f prometheus_deployment_svc.yaml

  Service type is nodeport.
  Once pod has been started successfully, you can hit the any of the kubernetes node IP with assigned port number.

> Grafana

  Create grafana using below helm command

    helm install stable/grafana -n grafana --namespace monitoring
  
# Logging

>  Elastic Search

   Create required persistent volume using below command.
        
        kubectl create -f pv-elastic-search.yaml
        
   Create elastic search service using below command. 
        
        kubectl create -f svc-elastic-search.yaml
    
   Create elastic search deployment using below command.
        
        kubectl create -f elastic-search-ss.yaml

> Kibana
        
   Create kibana service and deployment.
        
        kubectl create -f kibana-service-deployment.yaml
        
> Fluentd

   Create fluentd service account, cluster role and cluster role binding using below command.
        
        kubectl create -f sa-fluentd.yaml
        
   create fluentd deamon set which will aggregate the logs from all the node and send it to elastic search
        
        kubectl create -f ds-fluentd.yaml
