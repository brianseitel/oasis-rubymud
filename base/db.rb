require 'mysql2'
require 'active_record'

# Change the following to reflect your database settings
connection_details = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(connection_details)

# 
# A class to handle most DB and DB-like actions, such as loading data, populating DB, etc.
# 
# @author [brianseitel]
# 
class DB

	# 
	# Set up the database upon load. We truncate and re-populate certain tables on app load to ensure that we have the latest, greatest data
	# 
	def self.load_data
		# Drop all tables
		
		self.load_areas
		self.load_mobs
		# self.load_commands
		# self.load_socials
	end

	# 
	# Load the areas from the areas.json file in the DATA_DIR directory. This truncates the ```areas``` and ```rooms``` tables and fills them up again.
	# 
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

	# 
	# Load the mobs from the mobs.json file in the DATA_DIR directory. This truncates the ```mobs``` table and fills it up again.
	# 
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