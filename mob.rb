require 'active_record'

class Mob < ActiveRecord::Base
	attr_accessor :room

	@room = nil

	def update
		chance = Random.rand(2)
		if (chance == 1)
			do_move
		end
	end

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

	def spawn
		@room = Room.find(self.starting_room_id)
		World.mobs << self
	end
end