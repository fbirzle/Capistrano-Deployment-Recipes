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