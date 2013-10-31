require 'rubygems'
require 'bundler/setup'
require 'socket'

# 
# Helper function to get the current thread
# 
# @return Thread The current thread
def current_thread
	return Thread.current[:connection]
end

# 
# Get the current client (socket connection)
# 
# @return TCPSocket the socket that is currently connected to this thread
def current_client
	return current_thread.client
end

# 
# Get the player connected to this socket
# 
# @return Player The player connected to this socket
def current_player
	if current_thread
		return current_thread.player
	else
		return false
	end
end

# 
# The base MudServer class that instantiates and starts up everything, handles global vars and constances, and sets up a TCP server to listen for incoming connections.
# Once a socket connects, the MudServer spins off a thread and sends that player into a game loop.
# 
# @author [brianseitel]
# 
class MudServer
	@@clients = []
	@@players = []
	@@game_over = false

	
	# 
	# A global accessor for the list of all clients connected to the MudServer
	# 
	def self.clients
		@@clients
	end

	def self.logged_in?(player)
		MudServer.players.include? player
	end

	def self.get_player(player)
		MudServer.players.each do |p|
			if (player == p)
				return p
			end
		end
	end

	# 
	# A global accessor for the list of all players connected to the MudServer
	# 
	# @return [type] [description]
	def self.players
		@@players
	end

	# 
	# This method starts up a TCP server, loads DB data, spawns mobs, starts time, and accepts incoming sockets.
	# 
	def self.startup
		puts "Starting up server..."
		server = TCPServer.new(4000)

		# Big bang
		DB.load_data
		$world.spawn_mobs

		# Time starts now
		Thread.start do
			$world.update
		end

		# Wait for players!
		loop do 
			Thread.new(server.accept) do |client|
				@connection = Client.new(client)
				self.clients << @connection

				Thread.current[:connection] = @connection

				self.show_welcome

				while (!@connection.player)
					@player = self.login
					@player.client = client
					self.players << @player
					if (@player)
						@connection.player = @player
						@connection.room = Room.find(@player.room_id)
						@connection.area = Area.find(@player.area_id)
					end
				end

				client.puts "\nWelcome, #{@player.name}!\n"

				self.game_loop
			end
		end

	end

	# 
	# The game loop. It displays the current room, then waits for input.
	# 
	def self.game_loop
		input = nil
		Room.display current_thread.room

		while (!@@game_over)
			# Wait for input
			if (!input)
				input = self.await_input
			end
		end
	end

	# 
	# Accepts input and then passes that input into the Interpreter class
	# 
	def self.await_input
		current_player.show_status_prompt
		while (@input = current_client.gets.chomp("\r\n"))
			Interpreter.interpret(@input);
			current_player.show_status_prompt
		end
	end

	# 
	# The welcome screen for newly connected sockets
	# 
	def self.show_welcome
		current_client.puts "\n\n**** Welcome to Oasis! ***\n\n"
	end

		# 
	# This is the logic that signs up a new player
	# @param  name String name
	# 
	# @return Player the newly created player
	def self.do_new(name)
		@input = ""
		while (@input.downcase != "y" && @input.downcase != "n")
			current_client.puts "Are you a new player? [y/n]\n"
			@input = current_client.gets.chomp("\r\n")
		end

		if (@input == "n")
			return false
		end

		# Choose a password
		@password = "."
		@confirm = ""

		while (@password != @confirm)
			current_client.puts "Choose a password:"
			@password = current_client.gets.chomp("\r\n")

			current_client.puts "Confirm your password"
			@confirm = current_client.gets.chomp("\r\n")
		end

		player = Player.create(:name => name, :password => @password, :stats => [])
		return player
	end

	# 
	# The logic that asks a player to log in. If not found, it redirects to the New Player flow. If found, it returns a Player type.
	# 
	# @return Player the player that logged in
	def self.login
		found = false
		while (!found)
			current_client.puts "What's your name?\n"
			@input = current_client.gets.chomp("\r\n")
			@player = Player.find_by name: @input
			if (@player)
				current_client.puts "Enter password: "
				@password = current_client.gets.chomp("\r\n")

				@player = Player.find_by name: @input, password: @password

				if (@player)
					found = true
				else
					current_client.puts "Invalid password.\n\n"
				end
			else
				@player = self.do_new(@input)
				if (@player)
					found = true
				end
			end
		end
		return @player
	end
end

# 
# The base Client class that contains basic data about the connected client, such as the Player, Room, and Area connected to it.
# 
# @author [brianseitel]
# 
class Client
	attr_accessor :area
	attr_accessor :client
	attr_accessor :room
	attr_accessor :player

	def initialize(client_arg)
		@client = client_arg
	end
end