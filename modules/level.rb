
# 
# Module to handle level definitions, calculate level gains, modify attributes, and so on.
# 
# def gain_exp
# def gain_level
# @author [brianseitel]
# 
class Level

	EXP_TO_LEVEL = 1000

	# 
	# Calculate the amount of experience and increase the player's exp count/
	# @param  player Player the player gaining experience
	# @param  victim Mob|Player the victim
	# 
	# @return [type] [description]
	def self.gain_exp(player, victim)
		experience = victim.level * Random.rand(50) + Random.rand(100)
		p = MudServer.get_player player
		if (p)
			p.client.puts "You gain #{experience} experience points!"
		end

		player.experience += experience
		player.save

		if self.enough_to_level? player
			self.gain_level player
		end
	end

	# 
	# Does the player have enough experience to level? Possibly add other criteria here.
	# @param player Player the player we're checking
	# 
	# @return Boolean whether the player has enough xp to level
	def self.enough_to_level?(player)
		return player.experience > EXP_TO_LEVEL
	end

	# 
	# Increase the level of the player, modify stats if necessary
	# Output the level up screen
	# 
	# @param  player Player the player who leveled up!
	# 
	def self.gain_level(player)
		player.level += 1
		player.experience = 0
		player.save

		self.show_level_message player
	end

	# 
	# Display the level up screne for the player, if they're logged in 
	# @param  player Player the player who has leveled up
	# 
	def self.show_level_message(player)
		if (MudServer.logged_in? player)
			MudServer.clients.each do |client|
				if (client.player == player)
					client.puts View.render_template('player.levelup', player.level)
				end
			end
		end
	end

	def self.til_next(player)
		return EXP_TO_LEVEL - player.experience
	end
end