require 'rubygems'
require 'capistrano-buildpack'

set :application, "sites"
set :repository, "git@git.bugsplat.info:peter/sites.git"
set :scm, :git
set :additional_domains, %w(
  *.sites.subspace.bugsplat.info
)

role :web, "subspace.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 7600
set :concurrency, "web=1"

read_env 'prod'

load 'deploy'

before 'deploy' do
  run("mkdir -p #{shared_path}/sites")
end
