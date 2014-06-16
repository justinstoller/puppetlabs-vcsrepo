require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each {|host| on host, "mkdir -p #{host['distmoduledir']}" }
    puppet_module_install(:source => proj_root, :module_name => 'vcsrepo')
    hosts.each do |host|
      case fact_on(host, 'osfamily')
      when 'RedHat'
        if on(host, 'rpm -qa | grep epel-release', :acceptable_exit_codes => [0,1]).exit_code == 1
          case host['platform']
          when /el-4/
            on host, "curl https://dl.fedoraproject.org/pub/epel/4/i386/epel-release-4-10.noarch.rpm --insecure -o epel-release-4-10.noarch.rpm"
            on host, "rpm -i epel-release-4-10.noarch.rpm"
            on host, "yum makecache"
          when /el-5/
            on host, "rpm -i https://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm"
            on host, "yum makecache"
          end
        end

        if host['platform'] =~ /el-4/
          if on(host, 'which yum', :acceptable_exit_codes => [0,1]).exit_code == 0
            on host, 'yum install -y git'
          end
        else
          install_package(host, 'git') 
        end
      when 'Debian'
        install_package(host, 'git-core')
      when 'windows'
        install_package(host, 'git')
      else
        if !check_for_package(host, 'git')
          puts "Git package is required for this module"
          exit
        end
      end
      on host, 'git config --global user.email "root@localhost"'
      on host, 'git config --global user.name "root"'
    end
  end
end
