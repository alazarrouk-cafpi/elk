#--- packages
sudo apt-get update 
sudo apt install curl net-tools wget unzip openjdk-17-jdk



#---Nfs configuration
sudo apt-get install nfs-common
sudo modprobe nf_conntrack
echo "net.netfilter.nf_conntrack_max=131072" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo systemctl restart snap.microk8s.daemon-kubelite
