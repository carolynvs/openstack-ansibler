ssh -i ~/.ssh/id_rsa.osa root@xxx.xxx.xxx.xxx

adduser --shell /bin/bash --gecos "User" --home /home/osa osa
adduser osa sudo

mkdir /home/osa/.ssh
cp .ssh/authorized_keys /home/osa/.ssh/
chown -R osa:osa /home/osa/.ssh

sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
service ssh restart

apt-get -y update && apt-get -y upgrade
apt-get -y install git vim fail2ban

mkfs -t ext4 /dev/xvde
mkdir /var/lib/lxc
mount /dev/xvde /var/lib/lxc

git clone https://github.com/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible
git checkout liberty

export DEPLOY_CEILOMETER="no"
export DEPLOY_TEMPEST="yes" # creates a demo user (u: demo, p: demo)

scripts/bootstrap-ansible.sh
sed -i 's/keystone_auth_admin_password: .*/keystone_auth_admin_password: devstack/' /etc/openstack_deploy/user_secrets.yml
scripts/bootstrap-aio.sh
tmux new -d -s osa '/opt/openstack-ansible/scripts/run-playbooks.sh'
tmux attach -t osa
