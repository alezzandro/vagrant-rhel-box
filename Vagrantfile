# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  
  # Options for libvirt vagrant provider.
  
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    # If use ssh tunnel to connect to Libvirt.
    libvirt.connect_via_ssh = false
    # The username and password to access Libvirt. Password is not used when
    # connecting via ssh.
    libvirt.username = "root"
    #libvirt.password = "secret"
    # Libvirt storage pool name, where box image and instance snapshots will
    # be stored.
    libvirt.storage_pool_name = "default"
    # Set a prefix for the machines that's different than the project dir name.
    #libvirt.default_prefix = ''
  end
  config.vm.provider :libvirt do |domain|
    domain.memory = 1024
    domain.cpus = 2
    domain.nested = true
    domain.volume_cache = 'none'
  end
end
