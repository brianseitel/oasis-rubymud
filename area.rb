class Area
	
	def self.current_room
		areas = self.load_areas
		if (!current_thread.room)

			if (!current_thread.area)
				areas.each do |name, area|
					p "Checking #{name} area..."
					if (area['id'].to_i == current_user.area_id)
						current_thread.area = area
					end
				end
			end

			current_thread.area['rooms'].each do |room|
				if (room['id'] == current_user.room_id)
					current_thread.room = room
				end
			end
		end

		return current_thread.room
	end

	def self.find_room_by_id(area_id, room_id)
		areas = self.load_areas
		areas.each do |name, area|
			if (area['id'].to_i == area_id)
				this_area = area
			end

			this_area['rooms'].each do |room|
				if (room['id'] == room_id)
					return room
				end
			end
		end
		return []
	end


	def self.display_room
		current_room = self.find_room_by_id(current_user.area_id, current_user.room_id)

		current_client.puts current_room['description']
		self.show_exits current_room
		self.show_people current_room
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

	def self.show_people(room)
		users = []
		MudServer.clients.each do |connection|
			user = connection.user
			if (user.id != current_user.id && 
				user.area_id == current_user.area_id &&
				user.room_id == current_user.room_id)
				users << user.username
			end
		end

		if (users.uniq.length > 0)
			users.each do |u|
				current_client.puts "#{u} is here.\n"
			end
		end
	end
end