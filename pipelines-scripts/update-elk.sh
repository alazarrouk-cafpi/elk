echo 'Downloading the new configuration files'
rm -rf elk*
curl -L -o elk.zip https://github.com/alazarrouk-cafpi/elk/archive/refs/heads/main.zip 
unzip elk.zip


rm -rf /home/admala/mnt/data/elastalert-config/config/*
rm -rf /home/admala/mnt/data/elastalert-config/rules/*
rm -rf /home/admala/mnt/data/elastalert-config/custom_modules/*
cp -r  /home/admala/elk-main/elastalert/config/* /mnt/data/elastalert-config/config/
cp -r  /home/admala/elk-main/elastalert/rules/* /mnt/data/elastalert-config/rules/
cp -r  /home/admala/elk-main/elastalert/custom_modules/* /mnt/data/elastalert-config/custom_modules/


cat <<EOF > /etc/exports
/mnt/data/certs 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/fleet-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/logstash-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/kibana-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/es-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/elastalert-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/elastalert-config/config 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/elastalert-config/rules 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/elastalert-config/custom_modules 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/filebeatlogs-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
/mnt/data/filebeatmetrics-data 10.53.2.0/24(rw,sync,no_root_squash,no_subtree_check)
EOF
exportfs -a
systemctl restart nfs-kernel-server

microk8s kubectl apply -f /home/admala/elk-main/kubernetes/configMaps/
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/persistent-volumes/
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/persistent-volumes-claims/

microk8s kubectl delete deployment elastalert 
microk8s kubectl delete deployment es01
microk8s kubectl delete deployment filebeat-logs
microk8s kubectl delete deployment filebeat-metrics
microk8s kubectl delete deployment fleet
microk8s kubectl delete deployment kibana
microk8s kubectl delete deployment logstash
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/elasticsearch-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/logstash-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/kibana-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/fleet-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/filebeat-logs-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/filebeat-metrics-deployment.yaml
microk8s kubectl apply -f /home/admala/elk-main/kubernetes/elk-deployments/elastalert2-deployment.yaml