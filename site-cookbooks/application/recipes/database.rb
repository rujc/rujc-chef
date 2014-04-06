# Database

include_recipe 'postgresql::ruby'
include_recipe 'postgresql::client'
include_recipe 'postgresql::server'

application_environment = node.application.environment
database_yml_config = "#{application_shared_path}/config/database.yml"

template_variables = {
  application_environment: application_environment,
  database_host: 'localhost',
  database_name: node.application.db.name,
  database_username: node.application.db.username,
  database_password: node.application.db.password
}

postgresql_connection_info = {
  host: node.postgresql.config.listen_addresses,
  port: node.postgresql.config.port,
  username: 'postgres',
  password: node.postgresql.password.postgres
}

postgresql_database(node.application.db.name) do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user(node.application.db.username) do
  connection postgresql_connection_info
  password node.application.db.password
  action :create
end

postgresql_database_user(node.application.db.username) do
  connection postgresql_connection_info
  database_name node.application.db.name
  privileges [:all]
  action :grant
end

template database_yml_config do
  source "database.yml.erb"

  variables template_variables

  owner 'deployer'
  group 'deployer'
end
