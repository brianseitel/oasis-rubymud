# 
# Represents an Item in the game.
# 
# @author [brianseitel]
# 
class Item < ActiveRecord::Base

	# 
	# Spawn an item in its starting room
	# 
	def spawn
		@room = Room.find(self.room_id)
		$world.items << self
	end

end