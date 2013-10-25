require 'mysql2'
require 'active_record'

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter:  'mysql2', # or 'postgresql' or 'sqlite3'
  host:     'localhost',
  database: 'oasis_mud',
  username: 'root',
  password: ''
)