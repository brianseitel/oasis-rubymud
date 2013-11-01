# 
# The base world class that keeps track of things going on the world, such as time and all of the mobs present.
# 
# @author [brianseitel]
# 
class World
	@@last_time = nil
	@@current_time = nil

	@@mobs = []
	@@combats = []
	@@items = []

	def initialize
		@pulse_tick = setting('pulse_tick')
		@pulse_mob = setting('pulse_mob')
		@pulse_second = setting('pulse_second')
		@pulse_violence = setting('pulse_violence')
		@pulse_area = setting('pulse_area')

		@@last_time = Time.now
		@@current_time = Time.now
	end

	# 
	# Accessor for all the currently active combats in the world
	# 
	# @return Array all combats
	def combats
		@@combats
	end

	# 
	# A list of all the mobs that have been spawned
	# 
	def mobs
		@@mobs
	end

	def items
		@@items
	end

	# 
	# Do a pulse on a regular basis. This is independent of performance and based on time.
	# If enough time has passed, we trigger a pulse
	# 
	def update
		while (true)
			@@last_time = @@current_time
			
			do_pulse
			while (true)
				change = (Time.now.tv_sec  - @@last_time.tv_sec  ) * 1000 * 1000 + ( Time.now.tv_usec - @@last_time.tv_usec );
				if ( change >= 1000000 / setting('pulse_per_second'))
					break;
				end
			end

			@@last_time = Time.now
		end
	end

	# 
	# Update to the next pulse of time and take appropriate actions
	# 
	def do_pulse

		if ((@pulse_area -= 1) <= 0)
			min = setting('pulse_area') / 2
			max = 3 * setting('pulse_area') / 2
			@pulse_area = Random.rand(min..max)
			update_area
		end

		if ((@pulse_mob -= 1) <= 0)
			min = setting('pulse_mob') / 2
			max = 3 * setting('pulse_mob') / 2
			@pulse_mob = Random.rand(min..max)
			update_mobs
		end
		
		if ((@pulse_violence -= 1) <= 0)
			@pulse_violence = setting('pulse_violence')
			update_violence
		end

		if ((@pulse_tick -= 1) <= 0) 
			min = setting('pulse_tick') / 2
			max = 3 * setting('pulse_tick') / 2
			@pulse_tick = Random.rand(min..max)
			update_players
			update_objects
		end

		@@last_time = Time.now
	end

	# 
	# Update the area once per pulse. For now, this is just respawning monster
	# 
	# @todo respawn objects
	def update_area
		print "[UPDATE] Area\n".green
		$world.respawn_mobs
		$world.respawn_objects
	end

	# 
	# Update all mobs once per pulse.
	# 
	def update_mobs
		print "[UPDATE] Mobs\n".red
		$world.mobs.each do |mob|
			mob.update
		end
	end

	# 
	# Update players once per pulse. Increase health, mana, etc.
	# 
	def update_players
		print "[UPDATE] Players\n".cyan
		MudServer.players.each do |player|
			player.recover_health
			player.recover_mana
			player.show_status_prompt
		end
	end

	# 
	# Update objects once per pulse. Decay corpses, and so on
	# 
	def update_objects
		print "[UPDATE] Objects\n".white
	end

	# 
	# Update combat rounds once per pulse.
	# 
	def update_violence
		print "[UPDATE] Combat\n".yellow
		$world.combats.each do |combat|
			combat.do_attack
		end
	end

	# 
	# Spawns all of the mobs into their starting positions
	# 
	def spawn_mobs
		Mob.find_each do |mob|
			mob.spawn
		end
	end

	# 
	# Respawn any mobs that were killed. Only one mob per ID can exist at any given time. Maybe rethink this later, but for now it makes sense.
	# 
	def respawn_mobs
		Mob.find_each do |mob|
			if (!$world.mobs.include? mob)
				# 50/50 shot it gets respawned this tick
				if (Random.rand(2) == 1)
					mob.spawn
					mob.room.broadcast "#{mob.name} appears in a poof of smoke!", true
				end
			end
		end
	end

	def spawn_items
		Item.find_each do |item|
			item.spawn
		end
	end

	def respawn_items
		Item.find_each do |item|
			if (!$world.items.include? obj)
				if (Random.rand(2) == 1)
					item.spawn
				end
			end
		end
	end

end