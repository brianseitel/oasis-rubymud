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
# Get the user connected to this socket
# 
# @return User The user connected to this socket
def current_user
	if current_thread
		return current_thread.user
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
	@@game_over = false

	# 
	# A global accessor for the list of all clients connected to the MudServer
	# 
	def self.clients
		@@clients
	end

	# 
	# This method starts up a TCP server, loads DB data, spawns mobs, starts time, and accepts incoming sockets.
	# 
	def self.startup
		puts "Starting up server..."
		server = TCPServer.new(4000)

		# Big bang
		DB.load_data
		World.spawn_mobs

		# Time starts now
		Thread.start do
			World.update
		end

		# Wait for users!
		loop do 
			Thread.new(server.accept) do |client|
				@connection = Client.new(client)
				self.clients << @connection

				Thread.current[:connection] = @connection

				self.show_welcome

				while (!@connection.user)
					@user = self.login
					if (@user)
						@connection.user = @user
						@connection.room = Room.find(@user.room_id)
						@connection.area = Area.find(@user.area_id)
					end
				end

				client.puts "\nWelcome, #{@user.username}!\n"

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
		while (@input = current_client.gets.chomp("\r\n"))
			Interpreter.interpret(@input);
		end
	end

	# 
	# The welcome screen for newly connected sockets
	# 
	def self.show_welcome
		current_client.puts "\n\n**** Welcome to Oasis! ***\n\n"
	end

		# 
	# This is the logic that signs up a new user
	# @param  username String username
	# 
	# @return User the newly created user
	def self.do_new(username)
		@input = ""
		while (@input.downcase != "y" && @input.downcase != "n")
			current_client.puts "Are you a new user? [y/n]\n"
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

		user = User.create(:username => username, :password => @password, :area_id => 1, :room_id => 1)
		return user
	end

	# 
	# The logic that asks a user to log in. If not found, it redirects to the New User flow. If found, it returns a User type.
	# 
	# @return User the user that logged in
	def self.login
		found = false
		while (!found)
			current_client.puts "What's your name?\n"
			@input = current_client.gets.chomp("\r\n")
			@user = User.find_by username: @input
			if (@user)
				current_client.puts "Enter password: "
				@password = current_client.gets.chomp("\r\n")

				@user = User.find_by username: @input, password: @password

				if (@user)
					found = true
				else
					current_client.puts "Invalid password.\n\n"
				end
			else
				@user = self.do_new(@input)
				if (@user)
					found = true
				end
			end
		end
		return @user
	end
end

# 
# The base Client class that contains basic data about the connected client, such as the User, Room, and Area connected to it.
# 
# @author [brianseitel]
# 
class Client
	attr_accessor :area
	attr_accessor :client
	attr_accessor :room
	attr_accessor :user

	def initialize(client_arg)
		@client = client_arg
	end
end