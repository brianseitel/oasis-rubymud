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

			World.respawn_mobs
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

	# 
	# Respawn any mobs that were killed. Only one mob per ID can exist at any given time. Maybe rethink this later, but for now it makes sense.
	# 
	def self.respawn_mobs
		Mob.find_each do |mob|
			if (!World.mobs.include? mob)
				# 50/50 shot it gets respawned this tick
				if (Random.rand(2) == 1)
					mob.spawn
					mob.room.broadcast "#{mob.name} appears in a poof of smoke!", true
				end
			end
		end
	end
end