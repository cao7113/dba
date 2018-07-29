ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default) if defined? Bundler

$:.unshift File.join(__dir__, 'lib')
require 'dba'
require 'ext/sequel'
