require File.join(File.dirname(__FILE__), 'boot')
require "rubygems"

Rails::Initializer.run do |config|
#  config.action_controller.session = {
#    :session_key => '_example_rails_app',
#    :secret      => '78b197e00cca77859c1e77d6498d16cd'
#  }
end

def in_memory_database?
  ENV["RAILS_ENV"] == "test" and
  ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::SQLite3Adapter" and
  Rails::Configuration.new.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  puts "creating sqlite in memory database"
  # load "#{RAILS_ROOT}/db/schema.rb" # use db agnostic schema by default
  ActiveRecord::Migrator.up('db/migrate') # use migrations
end
