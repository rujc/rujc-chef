include_recipe 'ohai'
include_recipe 'apt'
include_recipe 'hostname'
include_recipe 'git'

node.packages.each do |package_name|
  package package_name
end

# Ruby
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.0.0-p451"
rbenv_gem "bundler" do
  ruby_version "2.0.0-p451"
end

# Users
user_account 'deployer' do
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3RjPMN81CWPl+EI/tK3tsyWItu2wNuUcqji/c0r9W8YZ/czZUPkeXraVer3XzYFIG1DVOLmUKZHc/+o7kCXNwwNGUi8dXckTrVsvVdY1169Bw33EyAD2RaRrDJHKllRw6VkGJaYT8LZWONTihMiXt+fKdoULL+g00X9ydT7BhdTflZRcdskQSfgfXdVuDMp4FKkMyRHAEAO9V5EbWprqlKNa7rvR/1AruYh2wsTS6yZ9vVIS82aQhjReXQMhqfIjgnZaOshbkDpAiat6ii/Y8xU2EYJb/ffInjV8+nqY07V1Z02Jae1NzRjJ1Jm27r2sdmUisAZMy6mbc2A/EoHQB me@maxprokopiev.com']

  action :create
end
include_recipe "sudo::default"

# Nginx
include_recipe 'nginx'

directory '/etc/nginx/sites-include' do
  mode 0755
end

application_name = node.application.name

directory node.application.root_prefix

application_environment = node.application.environment
application_domain = node.application.domain

application_root = "#{node.application.root_prefix}/#{application_name}"
application_current_path = "#{application_root}/current"
application_shared_path = "#{application_root}/shared"

unicorn_socket = "#{application_shared_path}/sockets/unicorn.sock"
unicorn_pid = "#{application_shared_path}/pids/unicorn.pid"
unicorn_log = "#{application_shared_path}/log/unicorn.log"
unicorn_config = "#{application_shared_path}/config/unicorn.rb"

database_yml_config = "#{application_shared_path}/config/database.yml"

# Create application folders
#
directory application_root do
  owner 'deployer'
  group 'deployer'
end

%W(releases shared shared/sockets shared/log shared/pids shared/config).each do |dir|
  directory "#{application_root}/#{dir}" do
    recursive true
    owner 'deployer'
    group 'deployer'
  end
end

# Setup nginx
#
template_variables = {
  application_environment: application_environment,
  application_name: application_name,
  application_domain: application_domain,
  application_root: application_root,
  application_current_path: application_current_path,
  application_shared_path: application_shared_path,
  unicorn_config: unicorn_config,
  unicorn_socket: unicorn_socket,
  unicorn_pid: unicorn_pid,
  unicorn_log: unicorn_log,
  unicorn_workers: 2,
  unicorn_timeout: 60,
  unicorn_user: 'deployer'
}

template "/etc/nginx/sites-include/#{application_name}.conf" do
  source 'app_nginx_include.conf.erb'

  variables template_variables

  notifies :reload, resources(service: 'nginx')
end

template "/etc/nginx/sites-available/#{application_name}" do
  source 'app_nginx.conf.erb'

  variables template_variables

  notifies :reload, resources(service: 'nginx')
end

nginx_site application_name do
  action :enable
end

# Setup unicorn
#
template unicorn_config do
  source 'unicorn.rb.erb'

  variables template_variables

  owner 'deployer'
  group 'deployer'
end

template "/etc/init.d/unicorn_#{application_name}" do
  source 'unicorn_init.erb'
  mode 0755
  variables template_variables
end

template database_yml_config do
  source "database.yml.erb"

  vars = {
    rails_env: application_environment
  }

  variables vars

  owner 'deployer'
  group 'deployer'
end
