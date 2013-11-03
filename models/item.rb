# 
# Represents an Item in the game.
# 
# @author [brianseitel]
# 
class Item < ActiveRecord::Base

	def self.load_data(data)
		item = Item.new
		data.each do |k, v|
			item[k] = v
		end

		return item
	end

	# 
	# Spawn an item in its starting room
	# 
	def spawn
		@room = Room.find(self.room_id)
		$world.items << self
	end

end