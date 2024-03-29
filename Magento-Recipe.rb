set :app_symlinks, ["/media", "/var", "/sitemaps", "/staging"]
set :app_shared_dirs, ["/app/etc", "/sitemaps", "/media", "/var", "/staging"]
set :app_shared_files, ["/app/etc/local.xml"]

namespace :mage do
  
  desc <<-DESC
      Prepares one or more servers for deployment of Magento. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com mage:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
  task :setup, :roles => :web, :except => { :no_release => true } do
    if app_shared_dirs
      app_shared_dirs.each { |link| run "#{try_sudo} mkdir -p #{shared_path}#{link} && chmod 777 #{shared_path}#{link}" }
    end
    if app_shared_files
      app_shared_files.each { |link| run "#{try_sudo} touch #{shared_path}#{link} && chmod 777 #{shared_path}#{link}" }
    end
  end

  desc <<-DESC
    Touches up the released code. This is called by update_code \
    after the basic deploy finishes. 
    
    Any directories deployed from the SCM are first removed and then replaced with \
    symlinks to the same directories within the shared location.
  DESC
  task :finalize_update, :roles => :web, :except => { :no_release => true } do    
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    
    if app_symlinks
      # Remove the contents of the shared directories if they were deployed from SCM
      app_symlinks.each { |link| run "#{try_sudo} rm -rf #{latest_release}#{link}" }
      # Add symlinks the directoris in the shared location
      app_symlinks.each { |link| run "ln -nfs #{shared_path}#{link} #{latest_release}#{link}" }
    end
    
    if app_shared_files
      # Remove the contents of the shared directories if they were deployed from SCM
      app_shared_files.each { |link| run "#{try_sudo} rm -rf #{latest_release}/#{link}" }
      # Add symlinks the directoris in the shared location
      app_shared_files.each { |link| run "ln -s #{shared_path}#{link} #{latest_release}#{link}" }
    end
  end 
  
  desc <<-DESC
    Clear the Magento Cache
  DESC
  task :cc, :roles => :web do
    run "cd #{current_path} && rm -rf var/cache/*"
  end
  
  desc <<-DESC
    Disable the Magento install by creating the maintenance.flag in the web root.
  DESC
  task :disable, :roles => :web do
    run "cd #{current_path} && touch maintenance.flag"    
  end 
  
  desc <<-DESC
    Enable the Magento stores by removing the maintenance.flag in the web root.
  DESC
  task :enable, :roles => :web do
    run "cd #{current_path} && rm -f maintenance.flag"    
  end   
end

after   'deploy:setup', 'mage:setup'
after   'deploy:finalize_update', 'mage:finalize_update'