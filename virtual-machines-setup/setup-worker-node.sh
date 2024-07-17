#--- packages
sudo apt-get update -y
sudo apt install curl net-tools wget unzip openjdk-17-jdk -y
sudo snap install microk8s --classic
sudo usermod -a -G microk8s admala
newgrp microk8s
sudo usermod -a -G microk8s admala
mkdir -p ~/.kube
chmod 0700 ~/.kube
chown -R admala ~/.kube
microk8s status --wait-ready
microk8s enable dns
microk8s enable storage


#---Nfs configuration
sudo apt-get install nfs-common -y 
sudo modprobe nf_conntrack
echo "net.netfilter.nf_conntrack_max=131072" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo systemctl restart snap.microk8s.daemon-kubelite
