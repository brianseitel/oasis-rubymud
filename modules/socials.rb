# 
# Accept input for social actions and process them accordingly. Socials are generally for aesthetic, not important interactions, such as smiling, waving, etc.
# 
# @author [brianseitel]
# 
class SocialInterpreter

	# 
	# Interprets the input and executes the social command
	# @param  value [String] The social action to execute
	# @param  target [Player OR Mob] The target entity upon which to perform the social action
	#
	def self.interpret(value, args)
		target = args[0]
		if (target.nil? || target.length == 0 || target == current_player.name)
			current_client.puts value['self']
		else
			found = false
			@target = nil
			MudServer.clients.each do |connection|
				player = connection.player
				if (player && player.name == target)
					found = true
					@target = connection
					break;
				end
			end

			if (found)
				current_client.puts value['target'].gsub('%1', target)
				if (@target)
					@target.client.puts value['other'].gsub('%1', current_player.name)
				end
			else
				current_client.puts "#{target} is not in the room, dummy!"
			end
		end
	end
end