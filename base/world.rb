# 
# The base World class that keeps track of things going on the world, such as time and all of the mobs present.
# 
# @author [brianseitel]
# 
class World
	@@last_time = nil
	@@current_time = nil
	@@tick_length = 10

	@@mobs = []
	@@combats = []

	def self.combats
		@@combats
	end

	# 
	# A list of all the mobs that have been spawned
	# 
	def self.mobs
		@@mobs
	end

	# 
	# Update to the next step of time. This currently operates in 15 second interals.
	# 
	# @todo Implement ticks
	def self.update
		@@current_time = Time.now
		# @ticks = (@@current_time - @@last_time / @@tick_length).to_i

		while (true)
			sleep 15
			p "... tick tock ..."
			World.mobs.each do |mob|
				mob.update
			end

			Combat.update_violence
		end

		@@last_time = Time.now
	end

	# 
	# Spawns all of the mobs into their starting positions
	# 
	def self.spawn_mobs
		Mob.find_each do |mob|
			mob.spawn
		end
	end
end