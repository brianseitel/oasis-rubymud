
# 
# Base Combat class. Handles initializing a combat scenario, updating combat events, calculating damage, and soon.
# 
# @todo  Differentiate between PC and NPC combats
# @todo  Create corpses
# @todo  Account for the effects of spells
# @todo  Account for armor in defense
# @todo  Account for weapons in office
# @todo  Figure out a better way to handle hit percentages and such
# 
# @author [brianseitel]
# 
class Combat
	attr_accessor :player
	attr_accessor :victim

	@player = nil
	@victim = nil

	# 
	# Start up a combat, involving a player and a victim.
	# @param  player Player The player initiating the attack
	# @param  victim Player|Mob The victim of the attack
	# 
	# @return Boolean whether the combat was successfully initiated or not
	def initialize(player, victim)
		@player = player
		@victim = victim

		if (@player == @victim)
			current_client.puts "You hit yourself! Ouch!\n"
			return false
		end

		in_combat = false
		$world.combats.each do |combat|
			if (combat.player == @player)
				in_combat = true
				break;
			end
		end

		if (in_combat)
			current_client.puts "You are doing the best you can!\n"
			return false
		end

		do_attack
		return true
	end

	# 
	# Begin the attack. Randomly determine who gets to attack first.
	# 
	# @todo  if this is the first attack, let the initiator hit first
	#
	def do_attack
		# If victim is dead or not in the room, skip
		if (@victim.is_dead? || @victim.room.id != @player.room_id)
			return
		end
		@player.state = Player::STATE_FIGHTING
		room = Room.find(@player.room_id)

		# who goes first?
		if (Random.rand(2) == 1)
			do_damage(@player, @victim, room)
			do_damage(@victim, @player, room)
		else
			do_damage(@victim, @player, room)
			do_damage(@player, @victim, room)
		end

		if (@victim.is_dead?)
			p = MudServer.get_player @player
			if (p.instance_of? Player)
				p.client.puts "You have KILLED #{@victim.name}!!\n"
			else
				p = MudServer.get_player @victim
				if (p.instance_of? Player)
					p.client.puts "You have KILLED #{@victim.name}!\n"
				end
			end
			combat_over
			Level.gain_exp @player, @victim
			@victim.die
		elsif (@player.is_dead)
			p = MudServer.get_player @victim
			if (p.instance_of? Player)
				p.client.puts "#{@victim.name} has KILLED you!\n"
			else
				p = MudServer.get_player @player
				if (p.instance_of? Player)
					p.client.puts "#{@victim.name} has KILLED you!\n"
				end
			end
			combat_over
			@player.die
		end
	end

	# 
	# Calculate and deal damage to victim
	# @param  attacker Player|Mob The entity doing the attacking
	# @param  defender Player|Mob The entity defending itself 
	# @param  room Room The room in which the combat occurs
	# 
	# @return [type] [description]
	def do_damage(attacker, defender, room)
		if (defender.is_dead? || attacker.is_dead?) 
			return
		end

		attacker_dmg = attacker.stats['strength'] + Random.rand(attacker.stats['strength'])
		diff = attacker.level - defender.level > 0 ? attacker.level - defender.level : 2 
		its_a_hit = Random.rand(diff)

		if (its_a_hit && attacker_dmg > 0)
			defender.hit_points -= attacker_dmg
			if (attacker == current_player)
				current_client.puts "You hit #{defender.name} for #{attacker_dmg} damage!\n"
			elsif (defender == current_player)
				current_client.puts "#{attacker.name} hits you for #{attacker_dmg} damage!\n"
			end
			room.broadcast "#{attacker.name} hits #{defender.name} for #{attacker_dmg} damage!\n"
		else
			if (attacker == current_player)
				current_client.puts "You swing at #{defender.name} and miss!\n"
			elsif (defender == current_player)
				current_client.puts "#{attacker.name} swings at you and misses!\n"
			end
			room.broadcast "#{attacker.name} swings at #{defender.name} and misses!\n"
		end
	end

	# 
	# End combat and remove it from the world's combat queue
	# 
	def combat_over
		@player.state = Player::STATE_STANDING
		$world.combats.each do |combat|
			if (combat == self)
				$world.combats.delete combat
				combat = nil
			end
		end
	end
end