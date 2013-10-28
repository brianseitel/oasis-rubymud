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
				elsif (target)
					return CommandInterpreter.send(value['method'], target)
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
