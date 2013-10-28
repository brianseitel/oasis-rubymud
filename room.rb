require 'active_record'

class Room < ActiveRecord::Base
	serialize :exits, JSON


	def self.display(room)
		current_client.puts room.title
		current_client.puts room.description + "\n"
		self.show_exits room
		self.show_people room
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

	def broadcast(message)
		connections = []
		MudServer.clients.each do |connection|
			user = connection.user
			if (user.id != current_user.id && 
				user.room_id == self.id)
				connection.client.puts message
			end
		end

	end
end