test_name "Installing Puppet and vcsrepo module" do
  step 'install puppet' do
    if @options[:provision]
      # This will fail if puppet is already installed, ie --no-provision
      if hosts.first.is_pe?
        install_pe
      else
        install_puppet
      end
    end
  end
  step 'install module' do
    proj_root = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))

    puppet_module_install(:source => proj_root, :module_name => 'vcsrepo')

    gitconfig = <<-EOS
[user]
	email = root@localhost
	name = root
EOS
    create_remote_file(hosts, "/root/.gitconfig", gitconfig)
  end
end
