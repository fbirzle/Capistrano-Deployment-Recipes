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
  
set :app_symlinks, ["wp-content/uploads"]
set :app_file_symlinks, ["wp-config.php", "sitemap.xml", "sitemap.xml.qz"]
namespace :wordpress do
  
  desc <<-DESC
      Prepares one or more servers for deployment of Wordpress. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com mage:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
  task :setup, :except => { :no_release => true } do
    if app_symlinks
      app_symlinks.each { |link| run "#{try_sudo} mkdir -p #{shared_path}/#{link}" }
    end
    if app_file_symlinks
      app_file_symlinks.each { |link| run "#{try_sudo} touch #{shared_path}/#{link} && chmod 777 #{shared_path}/#{link}" }
    end
  end

  desc <<-DESC
    Touches up the released code. This is called by update_code \
    after the basic deploy finishes. 
    
    Any directories deployed from the SCM are first removed and then replaced with \
    symlinks to the same directories within the shared location.
  DESC
  task :finalize_update, :except => { :no_release => true } do    
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    
    if app_symlinks
      # Remove the contents of the shared directories if they were deployed from SCM
      app_symlinks.each { |link| run "#{try_sudo} rm -rf #{latest_release}/#{link}" }
      # Add symlinks the directoris in the shared location
      app_symlinks.each { |link| run "#{try_sudo} ln -nfs #{shared_path}/#{link} #{latest_release}/#{link}" }
    end
    
    if app_file_symlinks
      # Remove the contents of the shared directories if they were deployed from SCM
      app_file_symlinks.each { |link| run "#{try_sudo} rm -f #{latest_release}/#{link}" }
      # Add symlinks the directoris in the shared location
      app_file_symlinks.each { |link| run "#{try_sudo} ln -s #{shared_path}/#{link} #{latest_release}/#{link}" }
    end
  end  
end

after  'deploy:setup', 'wordpress:setup'
after   'deploy:finalize_update', 'wordpress:finalize_update'