sudo apt-get remove --purge -y sysmonforlinux
sudo rm -rf /Elastic
sudo rm -rf /opt/Elastic
sudo systemctl stop elastic-agent
sudo systemctl disable elastic-agent
sudo rm /etc/systemd/system/elastic-agent.service
sudo rm -rf /var/log/elastic-agent
sudo rm -rf /etc/elastic-agent
sudo rm -rf /var/log/sysmon
