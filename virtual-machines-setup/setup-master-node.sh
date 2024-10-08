#!/bin/bash

#microk8s kubectl label node master-k8s node-role.kubernetes.io/master=master
#microk8s kubectl label node node01-k8s node-role.kubernetes.io/worker=worker
#microk8s kubectl label node node02-k8s node-role.kubernetes.io/worker=worker


sudo rm -rf /mnt/data/*
sudo mkdir -p /mnt/data/certs
sudo mkdir -p /mnt/data/elastalert-config/config
sudo mkdir -p /mnt/data/elastalert-config/custom_modules
sudo mkdir -p /mnt/data/elastalert-config/rules
sudo mkdir -p /mnt/data/elastalert-data
sudo mkdir -p /mnt/data/es-data
sudo mkdir -p /mnt/data/filebeatlogs-data
sudo mkdir -p /mnt/data/filebeatmetrics-data
sudo mkdir -p /mnt/data/fleet-data
sudo mkdir -p /mnt/data/kibana-data
sudo mkdir -p /mnt/data/logstash-data
sudo chmod 777 /mnt/data/certs
sudo chmod 777 /mnt/data/elastalert-config/
sudo chmod 777 /mnt/data/elastalert-data
sudo chmod 777 /mnt/data/es-data
sudo chmod 777 /mnt/data/filebeatlogs-data
sudo chmod 777 /mnt/data/filebeatmetrics-data
sudo chmod 777 /mnt/data/fleet-data
sudo chmod 777 /mnt/data/kibana-data
sudo chmod 777 /mnt/data/logstash-data

#---Nfs configuration
sudo apt-get update
sudo apt-get install nfs-kernel-server -y
sudo systemctl enable nfs-kernel-server -y

lines_to_add=(
"/mnt/data/certs 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/fleet-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/logstash-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/kibana-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/es-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-config/config 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-config/rules 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/elastalert-config/custom_modules 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/filebeatlogs-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
"/mnt/data/filebeatmetrics-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)"
)

for line in "${lines_to_add[@]}"
do
    echo "$line" | sudo tee -a /etc/exports > /dev/null
done

sudo exportfs -a
sudo systemctl restart nfs-kernel-server


#---container registery service principle secret 
microk8s kubectl create secret docker-registry elkimages-secret \
    --namespace default \
    --docker-server=elkimages.azurecr.io \
    --docker-username=df802705-25ee-4250-9860-0c01612bb0cd \
    --docker-password=sQj8Q~vEyiZAsr4xk3b8RNHBA8MJvLkFXFaj~a7Q
#----Creating kubernetes resources 
#curl -L -o elk.zip https://github.com/alazarrouk-cafpi/elk/archive/refs/heads/main.zip 
#unzip elk.zip 
#coping elastalert folders 
sudo cp -r elk-main/elastalert/config/* /mnt/data/elastalert-config/config/
sudo cp -r elk-main/elastalert/rules/* /mnt/data/elastalert-config/rules/
sudo cp -r elk-main/elastalert/custom_modules/* /mnt/data/elastalert-config/custom_modules/

#setup configMaps
microk8s kubectl apply -f elk-main/kubernetes/configMaps/env-configMap.yaml
microk8s kubectl apply -f elk-main/kubernetes/configMaps/filebeat-logs-configMap.yaml
microk8s kubectl apply -f elk-main/kubernetes/configMaps/filebeat-metrics-configMap.yaml
microk8s kubectl apply -f elk-main/kubernetes/configMaps/logstash-configMap.yaml
microk8s kubectl apply -f elk-main/kubernetes/configMaps/kibana-configMap.yaml
#setup pv's
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/certs-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/elastalert2-config-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/elastalert2-modules-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/elastalert2-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/elastalert2-rules-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/elasticsearch-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/filebeat-logs-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/filebeat-metrics-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/fleet-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/kibana-pv.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes/logstash-pv.yaml
#setup pvc's 
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/certs-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/elastalert2-config-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/elastalert2-modules-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/elastalert2-rules-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/elastalert2-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/elasticsearch-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/filebeat-logs-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/filebeat-metrics-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/fleet-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/kibana-pvc.yaml
microk8s kubectl apply -f elk-main/kubernetes/persistent-volumes-claims/logstash-pvc.yaml

microk8s kubectl delete deployment elastic-setup
microk8s kubectl delete deployment es01
microk8s kubectl delete deployment logstash
microk8s kubectl delete deployment kibana
microk8s kubectl delete deployment logstash
microk8s kubectl delete deployment fleet
microk8s kubectl delete deployment filebeat-logs
microk8s kubectl delete deployment filebeat-metrics
microk8s kubectl delete deployment elastalert


#setup deployments
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/elk-setup-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/elasticsearch-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/logstash-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/kibana-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/fleet-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/filebeat-logs-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/filebeat-metrics-deployment.yaml
microk8s kubectl apply -f elk-main/kubernetes/elk-deployments/elastalert2-deployment.yaml











