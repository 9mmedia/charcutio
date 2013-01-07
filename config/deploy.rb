require "bundler/capistrano"

set :application, "charcutio"

set :scm, :git
set :repository,  "git@github.com:9mmedia/charcutio.git"
set :deploy_to, "/usr/local/charcutio"
ssh_options[:forward_agent] = true

set :user, "pi"

# for rbenv
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

role :app, "10.10.10.157"

after "deploy" do
  run "sudo chmod a+x #{latest_release}/scripts/*.sh"

  # stop server
  run "cd #{latest_release} && bundle exec #{latest_release}/scripts/stop.sh"

  # start server
  run "cd #{latest_release} && bundle exec #{latest_release}/scripts/start.sh"
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
