# Setup nginx

include_recipe 'nginx'

directory '/etc/nginx/sites-include' do
  mode 0755
end

application_name = node.application.name
application_domains = node.application.domains
application_root = "#{node.application.root_prefix}/#{application_name}"
application_current_path = "#{application_root}/current"
application_shared_path = "#{application_root}/shared"

unicorn_socket = "#{application_shared_path}/sockets/unicorn.sock"

template_variables = {
  application_name: application_name,
  application_domains: application_domains,
  application_root: application_root,
  application_current_path: application_current_path,
  application_shared_path: application_shared_path,
  unicorn_socket: unicorn_socket,
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
