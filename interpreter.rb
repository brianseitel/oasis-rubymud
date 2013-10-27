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
				return CommandInterpreter.send(value['method'])
			end
		end

		# Check socials
		actions = JSON.parse(socials)

		actions.each do |key, value|
			if (key == command)
				return SocialInterpreter.interpret(value, target)
			end
		end

		return "I don't know what that means"
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
		return "You attack yourself with a knife. You die!"
	end

	def self.do_exit
		current_client.puts "Bye bye"
		current_client.close
	end

	def self.do_kill
		return "You attempt to kill yourself with a spatula. You fail spectacularly."
	end

	def self.do_look
		output = []
		begin
			MudServer.clients.each do |connection|
				if (connection.user)
					output << connection.user.username
				end
			end
		rescue Exception => e
			pp e
		end

		return output.join("\n")
	end
end

class SocialInterpreter

	def self.interpret(value, target)
		if (target.length == 0 || target == current_user.username)
			return value['self']
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
					begin
						@target.client.puts value['other'].gsub('%1', current_thread.user.username)
					rescue Exception => e
						pp e
					end
				end
			else
				return "#{target} is not in the room, dummy!"
			end
		end
	end
end