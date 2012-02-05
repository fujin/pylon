Vagrant::Config.run do |config|
  config.vm.define :cookbooks do |cookbooks|
    cookbooks.vm.customize do |vm|
      vm.memory_size = 4096
    end
    cookbooks.vm.box = "natty64"
    cookbooks.vm.box_url = "https://s3.amazonaws.com/hw-vagrant/natty64.box"
    cookbooks.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "pylon"
    end
  end
end
