# 
# Accept input for social actions and process them accordingly. Socials are generally for aesthetic, not important interactions, such as smiling, waving, etc.
# 
# @author [brianseitel]
# 
class SocialInterpreter

	# 
	# Interprets the input and executes the social command
	# @param  value [String] The social action to execute
	# @param  target [User OR Mob] The target entity upon which to perform the social action
	#
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