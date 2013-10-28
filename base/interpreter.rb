require 'rubygems'
require 'json'
require 'pp'

# 
# General interpreter class that routes actions to various sub-interpreters, such as CommandInterpreter and SocialInterpreter
# 
# @author [brianseitel]
# 
class Interpreter

	# 
	# Determine whether the input is a valid command, determine a target (if applicable), and redirect to appropriate interpreter
	# @param  input String The action that we want to interpret 
	# 
	# @return String the output of the action, if applicable
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

	# 
	# Load commands from commands.json file
	# 
	# @return Array The list of commands and their actions
	def self.loadCommands()
		return File.read("data/commands.json")
	end

	# 
	# Load socials from socials.json file
	# 
	# @return Array the list of socials and their output
	def self.loadSocials()
		return File.read("data/social.json")
	end

	# 
	# Get the command from the input (usually the first word)
	# @param  input String the entire input string
	# 
	# @return String the first word of the input
	def self.getCommand(input)
		return input.split(' ')[0]
	end


	# 
	# Get the rest of the argument, usually a target
	# @param  input String the entire input
	# 
	# @return String the rest of the argument, minus the first command
	def self.getTarget(input)
		return input.split(' ').drop(1).join(' ')
	end
end
