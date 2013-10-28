class CommandInterpreter

	def self.do_attack
		current_client.puts "You attack yourself with a knife. You die!"
	end

	def self.do_exit
		current_client.puts "Bye bye"
		current_client.close
	end

	def self.do_kill
		current_client.puts "You attempt to kill yourself with a spatula. You fail spectacularly."
	end

	def self.do_move(direction)
		room = current_thread.room

		case direction
		when "n"
			direction = "north"
		when "e"
			direction = "east"
		when "s"
			direction = "south"
		when "w"
			direction = "west"
		end

		if (room.exits.has_key? direction)
			new_room = Room.find(room.exits.values_at direction).first

			if (new_room)
				current_thread.room = new_room
				current_user.room_id = new_room.id
			end
		else
			current_client.puts "You can't move that way, dummy!\n"
		end

		case direction
			when "up"
				cardinality = "above"
			when "down"
				cardinality = "down"
			else
				cardinality = "the #{direction}"
		end
		room.broadcast "#{current_user.username} leaves to #{cardinality}.\n"
		Room.display new_room
		new_room.broadcast "#{current_user.username} enters from #{cardinality}.\n"
	end

	def self.do_look(target = nil)
		targObj = nil
		# if it's a room or there's no target, just display the room 
		if (!target or target.instance_of? Room)
			Room.display room
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
					if (person.username.downcase == target.downcase)
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
end