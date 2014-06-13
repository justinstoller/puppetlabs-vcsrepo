require 'puppetlabs_spec_helper/rake_tasks'
require 'rake'

Rake::Task['beaker'].clear

namespace :beaker do
  desc 'Run Beaker via RSpec'
  task :spec, [:host, :type] do |t,args|
    args.with_defaults(:host => 'default', :type => 'foss')
    set_env( args )
  
    sh "bundle exec rspec --color -P 'spec/acceptance/**/*_spec.rb'"
  end
  
  desc "Run beaker-rspec and beaker tests"
  task :all, [:host, :type] do |t,args|
    args.with_defaults(:host => 'default', :type => 'foss')
    set_env( args )
  
    Rake::Task['beaker:spec'].invoke
    Rake::Task['beaker:xunit'].invoke(args[:host], args[:type], *args.extras)
  end
  
  desc "Run Beaker using the older xUnit style runner"
  task :xunit, [:host, :type] do |t,args|
    args.with_defaults(:host => 'default', :type => 'foss')
    set_env( args )
  
    sh beaker_command
  end
end

def set_env( args )
  ENV['BEAKER_IS_PE'] = 'true' if args[:type] == 'pe'
  @type = args[:type]

  if args[:host].start_with?('/') # absolute path
    @hosts_config = ENV['BEAKER_setfile'] = args[:host]
  else
    ENV['BEAKER_set'] = args[:host]
    @hosts_config = "spec/acceptance/nodesets/#{args[:host]}.yml"
  end

  @keyfile = check_args_for_keyfile args.extras
  ENV['BEAKER_keyfile'] = @keyfile if @keyfile && File.exists?( @keyfile )
end

def beaker_command
  cmd = ["bundle exec beaker"]
  cmd << "--hosts #{@hosts_config}"

  if File.exists?("./.beaker-#{@type}.cfg")
    cmd << "--options-file ./.beaker-#{@type}.cfg"
  end

  if File.exists?('./spec/acceptance/beaker_helper.rb')
    cmd << "--pre-suite ./spec/acceptance/beaker_helper.rb"
  end

  if File.exists?("./spec/acceptance/beaker")
    cmd << "--tests ./spec/acceptance/beaker"
  end

  if @keyfile && File.exists?( @keyfile )
    cmd << "--keyfile #{@keyfile}"
  end

  cmd.join(" ")
end

def check_args_for_keyfile(extra_args)
  keyfile = nil
  extra_args.each do |a|
    keyfile = a unless (`ssh-keygen -l -f #{a}`.gsub(/\n/,"").match(/is not a .*key file/))
  end
  return keyfile
end
