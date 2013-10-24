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
				p key
				p value
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
		MudServer.socket.puts "Bye bye"
		MudServer.socket.close
	end

	def self.do_kill
		return "You attempt to kill yourself with a spatula. You fail spectacularly."
	end

end

class SocialInterpreter

	def self.interpret(value, target)
		if (target.length == 0)
			return value['self']
		else
			return value['target'].gsub('%1', target)
		end
	end

end