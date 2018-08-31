require_relative 'boot'

task default: :try

task sequel: 'sequel:debug'
namespace :sequel do
  task :debug do
    db = Sequel.connect('postgres://localhost/try')
    byebug
    puts
  end
end

desc 'run into a dba container sh '
task :dksh do
  exec "dockerdba down --dev && dockerdba sh --dev"
end

desc 'give generated shell commands'
task :dbsh do
  puts "pga copy postgres://src_db_url/db1 postgres://localhost_or_dest/new_db1 --dryrun"
end

task :conn do
  c = Dba::ConnectionBuilder.new(url: 'postgres://localhost/try')
  byebug
  puts
end

desc 'get pg testing env'
task :try do
  exec "DEBUG=1 rspec spec/try_db_spec.rb"
end

task :demo do
  exec "sql/demo.rb try"
end

namespace :demo do
  desc 'refresh sql/demo.rb'
  task :refresh do
    `rm sql/demo.rb`
    `mksqlet sql/demo.rb`
    puts "demo is refreshed"
    Rake::Task['demo'].invoke
  end
end
