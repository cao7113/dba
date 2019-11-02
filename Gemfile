# frozen_string_literal: true
source ENV['GEM_SOURCE'] || "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

def gem_fork(name, opts = {})
  repo = opts[:repo] || name
  lpath = "local/#{repo}"
  if File.exist?(lpath)
    gem name, path: lpath
  else
    gem name
  end
end

group :development do
  #gem "byebug"
end
## tools
#gem 'pry'
#gem 'pry-doc'
#gem 'pry-stack_explorer'
#gem 'pry-remote'
# irb-tools
#gem 'hirb' # great for table view
#gem 'awesome_print'
#gem 'table_print' # tp User.all, :name, :email, "jobs.title"

## cli
gem 'thor'
gem 'tty-prompt'
#gem "hanami-cli"

## base
gem "activesupport"

## db
gem "pg"
gem "sequel"

#gem "activerecord-import", require: false
#https://github.com/thuss/standalone-migrations
#gem 'standalone_migrations'

## test
group :test do
  gem "rspec"
end
