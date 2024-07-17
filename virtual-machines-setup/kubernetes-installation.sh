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
microk8s add-node | grep 'microk8s join' | grep -- '--worker' | sed 's/^ *//'
microk8s add-node | grep 'microk8s join' | grep -- '--worker' | sed 's/^ *//'