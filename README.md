# Kubernetes Test

Kubernetes HA Setup:
  
> Setup HA Proxy:
  
  1)Login the server where you are going run haproxy.
  2) Execute below commands
      apt-get update
      apt-get install haproxy
  3) Copy the HA_PROXY_Config file content into /etc/haproxy/haproxy.cfg file.
      systemctl restart haproxy

> Common Steps for Master and Worker node:

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

> Master Node Setup:
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

> Worker Node Setup:
   1) Copy the worker node join command from the init command's result and run it in the worker node which you want to join.
      kubeadm join 35.247.173.250:6443 --token pzt5xl.z7bm68alodd74wr3 \
      --discovery-token-ca-cert-hash sha256:c17eaac671c571bc40d56a4a255efd3494e523861cbdd1fa1fb1f44dcfa2237e
    
