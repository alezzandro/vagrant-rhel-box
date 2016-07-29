#version=RHEL7

# System authorization information
auth --enableshadow --passalgo=sha512
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Network information
network --bootproto=dhcp --onboot=on
services --enabled=network,sshd
# Root password = redhat
rootpw --iscrypted $6$huiciYFIrulM/UtY$eeGhAip7qwY6bYXoZMa8zbY1SLWpcVIpDW7FotRkaXpnp82cuLA/8cJL9BEobyP/2HRx4D/zcDAAzomMhdCFO/
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --location=mbr --boot-drive=vda

# Adding Vagrant user
user --name=vagrant --password=vagrant --gecos="Vagrant default user"

# Partition Information
zerombr
clearpart --all --initlabel
part / --size 8000 --fstype xfs --ondisk vda

#reboot
#halt
poweroff

# Repositories; gets wiped out by Brew
repo --name="rhel7" --baseurl=http://download.eng.bos.redhat.com/composes/released/RHEL-7/7.2/Server/x86_64/os/
repo --name="qe-cloud" --baseurl=http://download.eng.bos.redhat.com/rcm-guest/qeos-cloud-init/7.2/latest/x86_64/os/

# Packages
%packages
@core

# Extra packages for init vagrant commands
deltarpm
vim-enhanced
nfs-utils
yum-utils
rsync
tmux

# Pull "wireless adapter firmware" packages out
-*-firmware

%end

#
# Add custom post scripts after the base post.
#
%post --erroronfail

# make sure firstboot doesn't start
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

#To disable tunneled clear text passwords
sed -i 's|\(^PasswordAuthentication \)no|\1yes|' /etc/ssh/sshd_config

# SSH tweak - Avoiding a reverse DNS lookup on the connecting SSH client
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

# Setting up Vagrant password-less sudo
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Default insecure vagrant key
mkdir -m 0700 -p /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

%end
