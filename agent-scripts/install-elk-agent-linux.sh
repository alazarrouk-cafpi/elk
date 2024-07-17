wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y sysmonforlinux
sudo sysmon -i

cd /
sudo mkdir Elastic 
cd Elastic 
sudo  curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.14.3-linux-x86_64.tar.gz
sudo tar xzvf elastic-agent-8.14.3-linux-x86_64.tar.gz
cd elastic-agent-8.14.3-linux-x86_64
sudo mkdir certs
cd certs
sudo curl -o master.pem "https://sapfe01.blob.core.windows.net/elk-files/ssh-keys/master.pem?sp=rw&st=2024-07-14T16:28:08Z&se=2024-10-12T00:28:08Z&sv=2022-11-02&sr=b&sig=%2FEhIvLTBsu3zu9fOZvBQPB%2BU0K6oDdsv03u9v6vxvV8%3D"
sudo chmod 600 master.pem
sudo scp -o "StrictHostKeyChecking=no" -i "master.pem" admala@10.53.2.115:/mnt/data/certs/ca/ca.crt .
cd ..
credentials="elastic:Aloulou556"
url="http://135.236.136.224:30001/api/fleet/enrollment_api_keys"
response=$(curl -s -u "$credentials" --header 'kbn-xsrf: true' --request GET "$url")
enrollmentToken=$(echo "$response" | grep -oP '"list":\[\{"id":"[^"]*","active":true,"api_key_id":"[^"]*","api_key":"\K[^"]+' | sed 's/","name.*//')
sudo ./elastic-agent install --url=https://135.236.136.224:30002 --enrollment-token=$enrollmentToken --certificate-authorities="/Elastic/elastic-agent-8.14.3-linux-x86_64/certs/ca.crt"