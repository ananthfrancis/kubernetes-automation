// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("MyFirstProject-26a1a61564b9.json")}"
 project     = "positive-water-248212"
 region      = "asia-southeast1"
}

// Open firewall
resource "google_compute_firewall" "default" {
 name    = "kube-master"
 network = "default"

 allow {
   protocol = "icmp"
 }

 allow {
   protocol = "tcp"
   ports    = ["22","80","6443","8080"]
 }

 source_ranges = ["0.0.0.0/0"]
 target_tags = ["kube-master"]
}

// Google Cloud Engine instance for kubernetes master-1
resource "google_compute_instance" "k8s1" {
 name         = "k8s-master-1"
 machine_type = "n1-standard-2"
 zone         = "asia-southeast1-b"
 tags = ["kube-master"]
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 metadata_startup_script = "sudo apt-get -y update; sudo curl https://get.docker.com | sh - ; sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ; sudo echo 'deb http://apt.kubernetes.io kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list; sudo apt-get -y update; sudo apt-get -y install kubelet kubeadm kubectl; sudo swapoff -a"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
   
 }
}

// Google Cloud Engine instance for kubernetes master-2
resource "google_compute_instance" "k8s2" {
 name         = "k8s-master-2"
 machine_type = "n1-standard-2"
 zone         = "asia-southeast1-b"
tags = ["kube-master"]
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }


 metadata_startup_script = "sudo apt-get -y update; sudo curl https://get.docker.com | sh - ; sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ; sudo echo 'deb http://apt.kubernetes.io kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list; sudo apt-get -y update; sudo apt-get -y install kubelet kubeadm kubectl; sudo swapoff -a"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
   
 }
}

// Configure loadbalancer
resource "google_compute_forwarding_rule" "kube-master" {
  name   = "kube-master"
  region = "asia-southeast1"
  load_balancing_scheme = "EXTERNAL"
  target     = "${google_compute_target_pool.kube-master-target.self_link}"
  port_range = "6443"
}

resource "google_compute_health_check" "default" {
 name = "kube-health-check"
 timeout_sec        = 1
 check_interval_sec = 1

 tcp_health_check {
   port = "6443"
 }
}

// Configure target group which will point to kubernetes master instance
resource "google_compute_target_pool" "kube-master-target" {
  name = "kube-master-target"

  instances = [
    "asia-southeast1-b/k8s-master-1",
  ]



}

// Google Cloud Engine instance for kubernetes node-1
resource "google_compute_instance" "k8s-n1" {
 name         = "k8s-node-1"
 machine_type = "n1-standard-1"
 zone         = "asia-southeast1-b"
 tags = ["kube-master"]
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 metadata_startup_script = "sudo apt-get -y update; sudo curl https://get.docker.com | sh - ; sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ; sudo echo 'deb http://apt.kubernetes.io kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list; sudo apt-get -y update; sudo apt-get -y install kubelet kubeadm kubectl; sudo swapoff -a"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
   
 }
}

// Google Cloud Engine instance for kubernetes node-2
resource "google_compute_instance" "k8s-n2" {
 name         = "k8s-node-2"
 machine_type = "n1-standard-1"
 zone         = "asia-southeast1-b"
 tags = ["kube-master"]
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 metadata_startup_script = "sudo apt-get -y update; sudo curl https://get.docker.com | sh - ; sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ; sudo echo 'deb http://apt.kubernetes.io kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list; sudo apt-get -y update; sudo apt-get -y install kubelet kubeadm kubectl; sudo swapoff -a"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
   
 }
}
// GCE for Jenkins
resource "google_compute_instance" "jenkins" {
 name         = "jenkins"
 machine_type = "n1-standard-1"
 zone         = "asia-southeast1-b"
 tags = ["kube-master"]
 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 metadata_startup_script="sudo apt-get -y update;sudo curl https://get.docker.com | sh - ;sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ;sudo echo 'deb http://apt.kubernetes.io kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list;sudo apt-get -y update;sudo apt-get -y install kubectl;sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add - ;sudo echo 'deb https://pkg.jenkins.io/debian-stable binary/' >> /etc/apt/sources.list;sudo apt-get -y update;sudo apt-get -y install default-jdk"
 

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
   
 }
}

output "ip-external-lb" {
 value = "${google_compute_forwarding_rule.kube-master.ip_address}"
}

output "kube-master-1" {
 value = "${google_compute_instance.k8s1.network_interface.0.access_config.0.nat_ip}"
}

output "kube-master-2" {
 value = "${google_compute_instance.k8s2.network_interface.0.access_config.0.nat_ip}"
}

output "kube-node-1" {
 value = "${google_compute_instance.k8s-n1.network_interface.0.access_config.0.nat_ip}"
}

output "kube-node-2" {
 value = "${google_compute_instance.k8s-n2.network_interface.0.access_config.0.nat_ip}"
}

output "jenkins" {
 value = "${google_compute_instance.jenkins.network_interface.0.access_config.0.nat_ip}"
}

output "kube-master-1-name" {
 value = "${google_compute_instance.k8s1.name}"
}

output "kube-master-2-name" {
 value = "${google_compute_instance.k8s2.name}"
}

output "kube-node-1-name" {
 value = "${google_compute_instance.k8s-n1.name}"
}

output "kube-node-2-name" {
 value = "${google_compute_instance.k8s-n2.name}"
}

output "jenkins-name" {
 value = "${google_compute_instance.jenkins.name}"
}