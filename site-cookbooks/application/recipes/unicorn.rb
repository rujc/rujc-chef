# Setup unicorn

application_name = node.application.name

application_environment = node.application.environment
application_domains = node.application.domains

application_root = "#{node.application.root_prefix}/#{application_name}"
application_current_path = "#{application_root}/current"
application_shared_path = "#{application_root}/shared"

unicorn_socket = "#{application_shared_path}/sockets/unicorn.sock"
unicorn_pid = "#{application_shared_path}/pids/unicorn.pid"
unicorn_log = "#{application_shared_path}/log/unicorn.log"
unicorn_config = "#{application_shared_path}/config/unicorn.rb"

template_variables = {
  application_environment: application_environment,
  application_name: application_name,
  application_domains: application_domains,
  application_root: application_root,
  application_current_path: application_current_path,
  application_shared_path: application_shared_path,
  unicorn_config: unicorn_config,
  unicorn_socket: unicorn_socket,
  unicorn_pid: unicorn_pid,
  unicorn_log: unicorn_log,
  unicorn_workers: 2,
  unicorn_timeout: 60,
  unicorn_user: 'deployer',
}

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
