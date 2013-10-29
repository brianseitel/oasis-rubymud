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

		command = self.guess_command command, actions

		actions.each do |key, value|
			if (key == command && CommandInterpreter.respond_to?(value['method']))
				if (value['arg'])
					return CommandInterpreter.send(value['method'], value['arg'])
				elsif (target.length > 0)
					return CommandInterpreter.send(value['method'], target)
				else
					return CommandInterpreter.send(value['method'])
				end
			end
		end

		# Check socials
		actions = JSON.parse(socials)
		command = self.guess_command command, actions

		actions.each do |key, value|
			if (key == command)
				return SocialInterpreter.interpret(value, target)
			end
		end

		current_client.puts "I don't know what that means"
	end

	# 
	# Guess the command, given an input and a list of possible actions
	# @param  command String the input command
	# @param  actions Array a list of possible actions
	# 
	# @return String the final command to execute
	def self.guess_command(command, actions)
		commandkeys = actions.keys

		# See if we have an exact match first
		if (actions.has_key? command)
			return command
		end

		# If not, do a fuzzy search
		commandkeys.sort.each do |key|
			len = command.length - 1
			shortkey = key[0..len]
			if (shortkey == command)
				command = key
				break;
			end
		end

		command
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
