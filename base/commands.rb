# 
# Accept commands and interpret them accordingly. Commands generally require custom functions, as opposed to socials, which have a regular, predictable structure.
# 
# @author [brianseitel]
# 
class CommandInterpreter

	# 
	# Start a fight sequence between player and a target
	# @param target [Mob or Player] the entity the player wishes to fight
	# 
	def self.do_attack(target)
		target = target.downcase
		World.mobs.each do |mob|
			if (mob.room.id == current_player.room_id)
				len = target.length
				mobname = mob.name[0..len].downcase
				if (mobname == target)
					combat = Combat.new(current_player, mob)
					if (combat)
						World.combats << combat
					end
				end
			end
		end
	end

	def self.do_colors
		current_client.puts String.colors
	end

	def self.do_die
		current_player.die
	end

	# 
	# The player quits the game
	# 
	def self.do_exit
		current_client.puts "Bye bye"
		current_client.close
	end

	# 
	# Allow the player to look at a target. Targets may be Mobs or Players.
	# @param  target = nil [Mob or Player] the target at which the player wishes to look
	def self.do_look(target = nil)
		targObj = nil
		# if it's a room or there's no target, just display the room 
		if (target.nil? or target.instance_of? Room)
			Room.display(target.nil? ? current_thread.room : target)
			return

		# if we have a target, try and find it
		elsif (target.instance_of? String)
			mobs = Room.mobs_in_room current_thread.room
			mobs.each do |mob|
				if (mob.name.downcase == target.downcase)
					targObj = mob
				end
			end

			if (!targObj)
				people = Room.people_in current_thread.room
				people.each do |person|
					if (person.name.downcase == target.downcase)
						targObj = person
					end
				end
			end
		end

		if (targObj)
			current_client.puts targObj.long_description
		else
			current_client.puts "Look at what?"
		end
	end

	# 
	# Move the player from one room to another.
	# @param  direction [string] The direction through which to move. Acceptable values include: north, south, east, west, up, down
	# 
	def self.do_move(direction)
		room = current_thread.room

		if (room.exits.has_key? direction)
			new_room = Room.find(room.exits.values_at direction).first

			if (new_room)
				current_thread.room = new_room
				current_player.room_id = new_room.id
			end
		else
			current_client.puts "You can't move that way, dummy!\n"
			return
		end

		case direction
			when "up"
				cardinality = "above"
			when "down"
				cardinality = "down"
			else
				cardinality = "the #{direction}"
		end

		current_player.room_id = new_room.id
		room.broadcast "#{current_player.name} leaves to #{cardinality}.\n"
		Room.display new_room
		new_room.broadcast "#{current_player.name} enters from #{cardinality}.\n"
	end

	def self.do_score
		current_player.show_score
	end

	def self.do_stats
		current_player.show_stats
	end

	def self.do_who
		current_client.puts "Level\tName\n"
		current_client.puts "-" * setting('max_width')
		MudServer.players.each do |player|
			current_client.puts "[#{player.level}]\t#{player.name}"
		end
	end
end