#sudo apt-get update 
#sudo apt install curl net-tools wget unzip openjdk-17-jdk
#sudo snap install microk8s --classic
#sudo usermod -a -G microk8s $USER
#mkdir -p ~/.kube
#chmod 0700 ~/.kube
#microk8s status --wait-ready
#microk8s enable dns
#microk8s enable storage
#alias kubectl='microk8s kubectl' 


#kubectl label node master-k8s node-role.kubernetes.io/master=master
#kubectl label node node01-k8s node-role.kubernetes.io/worker=worker
#kubectl label node node02-k8s node-role.kubernetes.io/worker=worker

mkdir -p /mnt/data/certs
mkdir -p /mnt/data/elastalert-config/config
mkdir -p /mnt/data/elastalert-config/custom_modules
mkdir -p /mnt/data/elastalert-config/rules
mkdir -p /mnt/data/elastalert-data
mkdir -p /mnt/data/es-data
mkdir -p /mnt/data/filebeatlogs-data
mkdir -p /mnt/data/filebeatmetrics-data
mkdir -p /mnt/data/fleet-data
mkdir -p /mnt/data/kibana-data
mkdir -p /mnt/data/logstash-data

chmod 777 /mnt/data/certs
chmod 777 /mnt/data/elastalert-config/
chmod 777 /mnt/data/elastalert-data
chmod 777 /mnt/data/es-data
chmod 777 /mnt/data/filebeatlogs-data
chmod 777 /mnt/data/filebeatmetrics-data
chmod 777 /mnt/data/fleet-data
chmod 777 /mnt/data/kibana-data
chmod 777 /mnt/data/logstash-data

#---Nfs configuration
#sudo apt-get update
#sudo apt-get install nfs-kernel-server
#sudo apt-get enable nfs-kernel-server

lines_to_add=(
"/mnt/data/certs 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/fleet-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/logstash-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/kibana-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/es-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-config 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/filebeatlogsdata 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/filebeatmetricsdata 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
)

for line in "${lines_to_add[@]}"
do
    echo "$line" | sudo tee -a /etc/exports > /dev/null
done

sudo exportfs -a
sudo systemctl restart nfs-kernel-server






#---container registery service principle secret 
#kubectl create secret docker-registry elkimages-secret \
#    --namespace default\
#    --docker-server=elkimages.azurecr.io \
#    --docker-username=df802705-25ee-4250-9860-0c01612bb0cd \
#    --docker-password=sQj8Q~vEyiZAsr4xk3b8RNHBA8MJvLkFXFaj~a7Q

