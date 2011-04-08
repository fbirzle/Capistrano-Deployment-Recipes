namespace :module do
  desc <<-DESC
    Copy the most recent release of the project into the destination directory. This allows you to
    deploy new releases of a module and then copy them into place within a larger project. You should only use this
    when git submodules or symlinks are not an option.
      
    #{module_from} The location in your codebase to be copied.
    #{module_to} The location in the destination project the files should be copied to.
  DESC
  task :copy, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} cp -Rf #{latest_release}#{module_from} #{module_to}"
  end
end

after   'deploy:finalize_update', 'module:copy'
