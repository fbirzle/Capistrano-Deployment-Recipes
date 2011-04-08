namespace :memcached do
  desc <<-DESC
    Restart memcache post deployment so that are cache is clean and new functionality will be
    seen on the server.
  DESC
  task :restart, :roles => :db, :except => { :no_release => true } do
    run "#{try_sudo} service memcached restart"
  end
end

after   'deploy:finalize_update', 'memcached:restart'