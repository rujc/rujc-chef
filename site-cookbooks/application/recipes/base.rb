include_recipe 'ohai'
include_recipe 'apt'
include_recipe 'hostname'
include_recipe 'git'

node.set['build_essential']['compiletime'] = true

node.packages.each do |package_name|
  package package_name
end