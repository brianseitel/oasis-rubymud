require 'active_record'

class Room < ActiveRecord::Base
	serialize :exits, JSON


	def self.display(room)
		current_client.puts room.title
		current_client.puts room.description + "\n"
		self.show_exits room
		self.show_mobs room
		self.show_people room
	end

	def self.mobs_in_room(room)
		results = []
		World.mobs.each do |mob|
			if (mob.room.id == room.id)
				results << mob
			end
		end
		return results
	end
	def self.show_mobs(room)
		results = self.mobs_in_room room

		results.each do |mob|
			current_client.puts "#{mob.short_description}\n"
		end
	end

	def self.show_exits(room)

		results = []
		room.exits.as_json.each do |direction, id|
			results << direction
		end

		current_client.puts "Exits: " + results.join(" ")
	end

	def self.show_people(room)
		users = self.people_in room
		if (users.uniq.length > 0)
			users.each do |u|
				current_client.puts "#{u.username} is here.\n"
			end
		end
	end

	def self.people_in(room)
		users = []
		MudServer.clients.each do |connection|
			user = connection.user
			if (user.id != current_user.id && 
				user.room_id == room.id)
				users << user
			end
		end
		return users
	end

	def broadcast(message, mob = false)
		connections = []
		MudServer.clients.each do |connection|
			user = connection.user
			if (user.room_id == self.id)
				if (mob || (current_user && current_user.id != user.id))
					connection.client.puts message
				end
			end
		end

	end
end