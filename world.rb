class World
	@@last_time = nil
	@@current_time = nil
	@@tick_length = 10

	@@mobs = []

	def self.mobs
		@@mobs
	end

	def self.update
		@@current_time = Time.now
		# @ticks = (@@current_time - @@last_time / @@tick_length).to_i

		while (true)
			sleep 15
			p "... tick tock ..."
			World.mobs.each do |mob|
				mob.update
			end
		end

		@@last_time = Time.now
	end

	def self.spawn_mobs
		Mob.find_each do |mob|
			mob.spawn
		end
	end
end