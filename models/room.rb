require 'active_record'

# 
# The basic Room object. Handles all methods associated with a room, such as finding occupants (players or mobs), and showing descriptions, exits, and people.
# 
# @author [brianseitel]
# 
class Room < ActiveRecord::Base
	serialize :exits, JSON

	# 
	# Display the room to the player
	# @param  room Room The room to display
	# 
	def self.display(room)
		current_client.puts room.title
		current_client.puts room.description + "\n"
		self.show_exits room
		self.show_mobs room
		self.show_people room
	end

	# 
	# Figure out which mobs are in the room, if any.
	# @param  room Room The room to search
	# 
	# @return Array An array of mobs in the room
	def self.mobs_in_room(room)
		results = []
		World.mobs.each do |mob|
			if (mob.room.id == room.id)
				results << mob
			end
		end
		return results
	end

	# 
	# Display all of the mobs in the room
	# @param  room Room The room to display
	# 
	def self.show_mobs(room)
		results = self.mobs_in_room room

		results.each do |mob|
			current_client.puts "#{mob.short_description}\n"
		end
	end

	# 
	# Display all of the available exits in the room
	# @param  room Room The room whose exits we want to display
	# 
	def self.show_exits(room)
		results = []
		room.exits.as_json.each do |direction, id|
			results << direction
		end

		current_client.puts "Exits: " + results.join(" ")
	end

	# 
	# Show all of the people in the room
	# @param  room Room The room whose people we want to display
	# 
	def self.show_people(room)
		users = self.people_in room
		if (users.uniq.length > 0)
			users.each do |u|
				current_client.puts "#{u.username} is here.\n"
			end
		end
	end

	# 
	# Get a list of all the people in the room, if any.
	# @param  room Room The room to search
	# 
	# @return Array List of players in the room
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

	# 
	# Show a message to everyone in the room
	# @param  message String The message to broadcast
	# @param  include_player Boolean If true, show the message to everybody in the room
	# 
	def broadcast(message, include_player = false)
		connections = []
		MudServer.clients.each do |connection|
			user = connection.user
			if (user.room_id == self.id)
				if (include_player || (current_user && current_user.id != user.id))
					connection.client.puts message
				end
			end
		end

	end
end