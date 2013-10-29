require "rubygems"
require "bundler/setup"

require 'active_record'
require 'yaml'
require 'pp'

namespace :db do

  desc "Migrate the db"
  task :migrate do
    connection_details = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Create the db"
  task :create do
    connection_details = YAML::load(File.open('config/database.yml'))
    db = connection_details.fetch('database')
    ActiveRecord::Base.establish_connection(connection_details.except('database'))
    ActiveRecord::Base.connection.create_database(db)
  end

  desc "drop the db"
  task :drop do
    connection_details = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end
end