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
					@user = User.login
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