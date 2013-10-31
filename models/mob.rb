require 'active_record'
require 'active_support'
# 
# The Mob model. "Mob" is short for "mobile", which basically just means that it's a mobile object in the game. Mobs are usually monsters, though they can be NPCs as well.
# 
# @author [brianseitel]
# 
class Mob < ActiveRecord::Base
	attr_accessor :room

	# 
	# If hit points are below zero, this mob is dead. Seeya.
	# 
	# @return Boolean whether the mob is dead or not
	def is_dead?
		return self.hit_points <= 0
	end


	# 
	# Broadcast to the room that this mob is dead, then delete the mob from the $world.
	# 
	def die
		self.room.broadcast "#{self.name} is DEAD!!!"
		$world.mobs.each do |mob|
			if (mob == self)
				$world.mobs.delete(mob)
				return
			end
		end
	end

	# 
	# Mobs don't gain experience, so this is just a placeholder for now.
	# 
	# @todo Change it so that Mobs don't even get this far
	def gain_exp(victim)

	end

	def stats
		stats = {
			"strength" => 12,
			"constitution" => 12,
			"intelligence" => 12,
			"dexterity" => 12,
			"charisma" => 12,
			"wisdom" => 12
		}
	end
	
	# 
	# The update lifecycle of a mob. Currently just whether or not the mob moves around. If so, move it.
	# 
	# @todo If aggressive mob, determine whether to attack player
	def update
		chance = Random.rand(2)
		if (chance == 1)
			do_move
		end
	end

	# 
	# Analyze the exits in the current room and decide whether to move or not. Also, broadcast the move to the room.
	# 
	# @todo Add "sneak" support
	def do_move
		possible_moves = @room.exits.keys
		choice = Random.rand(possible_moves.length)
		
		case possible_moves[choice]
			when "up"
				cardinality = "above"
			when "down"
				cardinality = "down"
			else
				cardinality = "the #{possible_moves[choice]}"
		end

		@room.broadcast "#{self.name} leaves to #{cardinality}.", true
		@room = Room.find(@room.exits.values_at possible_moves[choice]).first
		@room.broadcast "#{self.name} enters from #{cardinality}.\n", true
	end


	# 
	# Spawn a new instance of this mob in its starting room and add the mob to the world mob list.
	# 
	def spawn
		@room = Room.find(self.starting_room_id)
		$world.mobs << self
	end
end