!#/bin/bash

sudo yum install -y wget
sudo yum install -y nano
wget https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.2.0-1.el6.x86_64.rpm -O chef.rpm

rpm -Uvh chef.rpm

selinux() {
  cat > /etc/sysconfig/selinux <<EOF
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted

EOF
}
firewall() {
  chkconfig iptables off
EOF
}

chefConfig() {
  cat >> /etc/opscode/chef-server.rb <<EOF
server_name = "chefserver.novalocal"
api_fqdn server_name
bookshelf['vip'] = server_name
nginx['url'] = "https://#{server_name}"
nginx['server_name'] = server_name
nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/#{server_name}.crt"
nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/#{server_name}.key"

EOF
}
inputHost() {
  cat >> /etc/hosts <<EOF
10.2.0.13 server
EOF
}

sudo chef-server-ctl reconfigure

sudo chef-server-ctl install opscode-manage
sudo chef-server-ctl reconfigure
sudo opscode-manage-ctl reconfigure

sudo chef-server-ctl install opscode-reporting
sudo chef-server-ctl reconfigure
sudo opscode-reporting-ctl reconfigure

rm -rf chef.rpm

selinux
firewall
chefConfig
inputHost


