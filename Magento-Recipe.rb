set :application, "magentoapp"
set :repository,  "svn+ssh://PATH_TO_YOUR_RELEASE_BRANCH"

# If you aren't deploying to /var/www/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/DEPLOYMENT_PATH_HERE/#{application}"

# If there's no access to the repository from the production server, deploy via uploading tarball to the server
#set :deploy_via, :copy

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

# Application server|servers [APLICATION_SERVER, "WEB_SERVER", "DATABASE_SERVER"] hostnames or IPs accessible from the client terminal
role :app, "APPLICATION_SERVER_HERE"
role :web, "WEB_SERVER_HER"
role :db,  "DB_SERVER_HERE", :primary => true

# The username of the user who can access the machines
set :user, "USERNAME_HERE"

# path to php executable 
set :php, "/usr/local/php5/bin/php5"

namespace (:deploy) do

  desc <<-DESC
    [internal] Overriding original Capistrano task to fit to Magento project needs
  DESC
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    run <<-CMD
      rm -rf #{latest_release}/log &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD
    
    run <<-CMD
      rm -rf #{latest_release}/cache &&
      ln -s #{shared_path}/cache #{latest_release}/cache
    CMD
    
    stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
    asset_paths = %w(images css js).map { |p| "#{latest_release}/web/#{p}" }.join(" ")
    run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
  end
  
  desc <<-DESC
    Overriding original Capistrano task to exclude the application restart
  DESC
  task :default do
    update
  end
  
  desc <<-DESC
    Overriding original Capistrano task to exclude any database migration
  DESC
  task :migrations do
    update
  end  
  
  after "deploy:update", 'deploy:customize'
  
  desc <<-DESC
    Custom tasks that are required to deploy Magento specifically
  DESC
  task :customize do
    # custmize it here
    # Setup symlinks to shared files e.g. config|media|var
    mage.symlinks 
    # Clear the config|page cache from files system|memcache
    mage.cc
  end
  
end


namespace (:mage) do

  desc <<-DESC
    Clear the Magento Cache
  DESC
  task :cc do
    run "cd #{current_path} && rm -rf var/cache/*"
  end

  desc <<-DESC
    Create symlink to shared Magento|CDN specific targets
  DESC
  task :symlinks do
    # symlink to config
    run "rm -rf #{current_path}/app/etc/local.xml"
    run "ln -s #{shared_path}/app/etc/local.xml #{current_path}/app/etc/local.xml"
    
    # symlink to media dir
    run "rm -rf #{current_path}/media"
    run "ln -s #{shared_path}/media #{current_path}/media"

    # symlink to var dir   
    run "rm -rf #{current_path}/var"
    run "ln -s #{shared_path}/var #{current_path}/var"
    
    # symlink to sitemap dir   
    run "rm -rf #{current_path}/sitemap"
    run "ln -s #{shared_path}/sitemap #{current_path}/sitemap"
  end 
  
  desc <<-DESC
    Disable the Magento stores
  DESC
  task :disable do
    run "cd #{current_path} && touch maintenance.flag"    
  end 
  
  desc <<-DESC
    Enable the Magento stores
  DESC
  task :enable do
    run "cd #{current_path} && rm -f maintenance.flag"    
  end   
end