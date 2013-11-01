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
		$world.mobs.each do |mob|
			if (mob.room.id == current_player.room_id)
				len = target.length
				mobname = mob.name[0..len].downcase
				if (mobname == target)
					combat = Combat.new(current_player, mob)
					if (combat)
						$world.combats << combat
					end
				end
			end
		end
	end

	# 
	# Helper method to show color options
	# 
	def self.do_colors
		current_client.puts String.colors
	end

	# 
	# Commit suicide
	# 
	def self.do_die
		current_player.die
	end

	# 
	# Instantly transport user to new room. DEV ONLY
	# @param  room_id Integer The room ID to which to transport the user
	# 
	# @todo restrict to Immortals only
	def self.do_goto(room_id)
		current_player.goto_room(room_id)
	end

	# 
	# The player quits the game
	# 
	def self.do_exit
		MudServer.players.each do |player|
			if (player == current_player)
				MudServer.players.delete player
			end
		end

		MudServer.clients.each do |client|
			if (client.client == current_client)
				client.client.puts "Bye bye!"
				client.client.close
				MudServer.clients.delete client
			end
		end

		Thread.current.kill
	end

	# 
	# Allow the player to look at a target. Targets may be Mobs or Players.
	# @param  target = nil [Mob or Player] the target at which the player wishes to look
	def self.do_look(target = nil)
		targObj = nil
		# if it's a room or there's no target, just display the room 
		if (target.nil? or target.instance_of? Room)
			room = Room.find(current_player.room_id)
			Room.display(target.nil? ? room : target)
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

		player = MudServer.get_player current_player

		if (player.state != Player::STATE_STANDING)
			case player.state
				when Player::STATE_FIGHTING
					current_client.puts "You're too busy fighting!\n"
					return
				when Player::STATE_SLEEPING
					current_client.puts "Wake up first, dummy!\n"
					return
				when Player::STATE_DEAD
					current_client.puts "You're dead, idiot!\n"
					return
			end
		end

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

	# 
	# Command to show the score
	# 
	def self.do_score
		current_player.show_score
	end

	# 
	# Command to make the player stand up
	# 
	# @todo Show error messages, depending on player state. If player is dead, they can't stand up, etc.
	def self.do_stand
		current_player.state = Player::STATE_STANDING
		current_client.puts "You stand up.\n"
	end

	# 
	# Show stats screen
	# 
	def self.do_stats
		current_player.show_stats
	end

	# 
	# Show a list of all active players
	# 
	def self.do_who
		current_client.puts "Level\tName\n"
		current_client.puts "-" * setting('max_width')
		MudServer.players.each do |player|
			current_client.puts "[#{player.level}]\t#{player.name}"
		end
	end
end