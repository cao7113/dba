# frozen_string_literal: true
source ENV['GEM_SOURCE'] || "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "byebug"
#gem 'pry'
gem "rspec"
gem "activesupport"

gem "pg"
gem "sequel"
#gem "hanami-cli"
#gem 'migrations', github: 'cao7113/migrations'
#gem 'sequel-postgres-schemata', path: 'refs/sequel-postgres-schemata'

def forked_gem(name, repo)
  path = "lfork/#{repo}"
  opts = if File.exists?(path)
    { path: path }
  else
    { github: "cao7113/#{repo}", branch: 'zhulu' }
  end
  gem name, opts 
end

#forked_gem "pg_tester", 'pgtester'
