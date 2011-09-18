def pylon_vm(config=nil, name=:pylon, count=0)
  return unless config
  config.vm.define(name) do |config|
    config.vm.box = 'natty64_cloudscaling_4.1'
    config.vm.box_url = "http://d1lfnqkkmlbdsd.cloudfront.net/vagrant/natty64_cloudscaling_4.1.box"
    config.vm.network "33.33.33.#{10 + count}"
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "pylon"
    end
  end
end

Vagrant::Config.run do |config|
  10.times do |i|
    pylon_vm(config, "pylon#{i}".to_sym, i)
  end
end
