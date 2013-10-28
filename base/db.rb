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

class DB

	def self.load_data
		# Drop all tables
		
		self.load_areas
		self.load_mobs
		# self.load_commands
		# self.load_socials
	end

	def self.load_areas
		conn = ActiveRecord::Base.connection
		conn.execute("TRUNCATE areas")
		conn.execute("TRUNCATE rooms")

		file = File.read(DATA_DIR + "areas.json")
		areas = JSON.parse(file)

		areas.each do |name, data|
			area = Area.create(:name => name)
			data['rooms'].each do |room|
				room['area_id'] = area.id
				Room.create(room)
			end
		end
	end

	def self.load_mobs
		conn = ActiveRecord::Base.connection
		conn.execute("TRUNCATE mobs")

		file = File.read(DATA_DIR + "mobs.json")
		mobs = JSON.parse(file)

		mobs['mobs'].each do |data|
			Mob.create(data)
		end
	end
end