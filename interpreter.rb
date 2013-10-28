require 'rubygems'
require 'json'
require 'pp'

class Interpreter

	def self.interpret(input)
		commands = self.loadCommands()
		socials  = self.loadSocials()

		# Check commands first
		actions = JSON.parse(commands)

		command = self.getCommand(input)
		target  = self.getTarget(input)

		actions.each do |key, value|
			if (key == command && CommandInterpreter.respond_to?(value['method']))
				if (value['arg'])
					return CommandInterpreter.send(value['method'], value['arg'])
				else
					return CommandInterpreter.send(value['method'])
				end
			end
		end

		# Check socials
		actions = JSON.parse(socials)

		actions.each do |key, value|
			if (key == command)
				return SocialInterpreter.interpret(value, target)
			end
		end

		current_client.puts "I don't know what that means"
	end

	def self.loadCommands()
		return File.read("data/commands.json")
	end

	def self.loadSocials()
		return File.read("data/social.json")
	end

	def self.getCommand(input)
		return input.split(' ')[0]
	end

	def self.getTarget(input)
		return input.split(' ').drop(1).join(' ')
	end
end

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

	def self.do_look(room = nil)
		if (!room)
			room = current_thread.room
		end
		Room.display room
	end
end

class SocialInterpreter

	def self.interpret(value, target)
		if (target.length == 0 || target == current_user.username)
			current_client.puts value['self']
		else
			found = false
			@target = nil
			MudServer.clients.each do |connection|
				user = connection.user
				if (user && user.username == target)
					found = true
					@target = connection
					break;
				end
			end

			if (found)
				current_client.puts value['target'].gsub('%1', target)
				if (@target)
					@target.client.puts value['other'].gsub('%1', current_user.username)
				end
			else
				current_client.puts "#{target} is not in the room, dummy!"
			end
		end
	end
end