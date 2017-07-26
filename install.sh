sudo apt-get update
sudo apt-get -y upgrade

# Basic stuff for a friendly enviroment
sudo apt-get install -y vim htop iotop nload sysbench pigz rsync git tmux tree nmap ghostscript curl

# Optional
# sudo apt-get install shellinabox

# Basic stuff for seafile
# sudo apt-get install -y python python2.7 libpython2.7 python-setuptools python-imaging python-ldap python-mysqldb python-memcache python-urllib3

# Stuff for a seafile server instance
# sudo apt-get install -y mysql-server nginx memcached

sudo apt-get -y autoclean
sudo apt-get -y autoremove
