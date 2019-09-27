#Prepare the system
sudo apt-get update && sudo apt-get upgrade

#Install Postgresql and create the User with the DB
sudo apt-get install postgresql postgresql-contrib
sudo -u postgres bash -c "psql -c \"CREATE USER concourse WITH PASSWORD 'concourse';\""
sudo -u postgres createdb --owner=concourse atc


#Install Concource V5.5.1 app
cd /tmp
curl -LO https://github.com/concourse/concourse/releases/download/v5.5.1/concourse-5.5.1-linux-amd64.tgz
curl -LO https://github.com/concourse/concourse/releases/download/v5.5.1/fly-5.5.1-linux-amd64.tgz
tar zxvf concourse*.tgz
tar zxvf fly*.tgz
chmod +x concourse* fly*
sudo mv concourse/bin/* /usr/local/bin
sudo mv fly* /usr/local/bin


#Create the Concourse CI Configuration Assets
sudo mkdir /etc/concourse
sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/tsa_host_key
sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/worker_key
sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/session_signing_key
sudo cp /etc/concourse/worker_key.pub /etc/concourse/authorized_worker_keys


#Creating the Environment Configuration Files
sudo cp web_environment /etc/concourse/web_environment
sudo cp worker_environment /etc/concourse/worker_environment


#Creating a Dedicated System User and Adjusting Permissions
sudo adduser --system --group concourse
sudo chown -R concourse:concourse /etc/concourse
sudo chmod 600 /etc/concourse/*_environment


#Create Systemd Unit Files for the Web and Worker Processes
sudo cp concourse-web.service /etc/systemd/system/concourse-web.service
sudo cp concourse-worker.service /etc/systemd/system/concourse-worker.service


sudo systemctl start concourse-web concourse-worker
sudo systemctl enable concourse-web concourse-worker
sudo systemctl status concourse-web concourse-worker



