class Area
	
	def self.display_room
		areas = self.load_areas
		area_id = current_user.area_id
		room_id = current_user.room_id

		if (!current_thread.room)

			if (!current_thread.area)
				areas.each do |name, area|
					p "Checking #{name} area..."
					if (area['id'].to_i == area_id)
						current_thread.area = area
					end
				end
			end

			current_thread.area['rooms'].each do |room|
				if (room['id'] == room_id)
					current_thread.room = room
				end
			end
		end

		current_client.puts current_thread.room['description']
		self.show_exits current_thread.room
	end

	def self.load_areas
		file = File.read("data/areas.json")
		return JSON.parse(file)
	end

	def self.show_exits(room)
		exits = []
		room['exits'].each do |direction, id|
			exits << direction
		end

		current_client.puts "Exits: " + exits.join(" ")
	end
end