# Create application folders

application_name = node.application.name
application_root = "#{node.application.root_prefix}/#{application_name}"

directory node.application.root_prefix

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
