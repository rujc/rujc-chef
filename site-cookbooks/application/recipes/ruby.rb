# Ruby
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.0.0-p451"
rbenv_gem "bundler" do
  ruby_version "2.0.0-p451"
end
