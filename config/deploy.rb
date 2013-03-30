set :rvm_ruby_string, '1.9.3'
set :rvm_type, :system

require 'rvm/capistrano'
require 'bundler/capistrano'
load 'deploy/assets'
load 'config/deploy/recipes/unicorn'

set :application, "boxroom"
set :repository,  "git@github.com:ekadoo/boxroom.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "domain.com"                          # Your HTTP server, Apache/etc
# role :app, "domain.com"                          # This may be the same as your `Web` server
# role :db,  "domain.com", :primary => true # This is where Rails migrations will db-server here"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

set :deploy_to, "/home/#{ENV['DEPLOYER_USER']}/rails_apps/#{application}"

set :user, ENV['DEPLOYER_USER']
set :use_sudo, false
set :ssh_options, {:forward_agent => true}

set :default_environment, {
  'SMTP_DOMAIN' => ENV['SMTP_DOMAIN'],
  'SMTP_USERNAME' => ENV['SMTP_USERNAME'],
  'SMTP_PASSWORD' => ENV['SMTP_PASSWORD'],
  'DEFAULT_URL_HOST' => ENV['DEFAULT_URL_HOST'],
  'SMTP_EMAIL_FROM' => ENV['SMTP_EMAIL_FROM'],
  'SMTP_AUTH' => ENV['SMTP_AUTH']
}

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

after "deploy:create_symlink" do
  run "if [ ! -f #{shared_path}/production.sqlite3 ]; then touch #{shared_path}/production.sqlite3; fi; ln -s #{shared_path}/production.sqlite3 #{release_path}/db/production.sqlite3"
end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    unicorn.start
  end
  task :stop do
    unicorn.stop
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    unicorn.restart
  end
end
