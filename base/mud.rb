require 'rubygems'
require 'bundler/setup'
require 'socket'

def current_thread
	return Thread.current[:connection]
end

def current_client
	return current_thread.client
end

def current_user
	if current_thread
		return current_thread.user
	else
		return false
	end
end

class MudServer
	@@clients = []
	@@game_over = false

	def self.clients
		@@clients
	end

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

	def self.game_loop()
		input = nil
		Room.display current_thread.room

		while (!@@game_over)
			# Wait for input
			if (!input)
				input = self.await_input
			end
		end
	end

	def self.await_input
		while (@input = current_client.gets.chomp("\r\n"))
			Interpreter.interpret(@input);
		end
	end


	def self.show_welcome
		current_client.puts "\n\n**** Welcome to Oasis! ***\n\n"
	end
end

class Client
	attr_accessor :area
	attr_accessor :client
	attr_accessor :room
	attr_accessor :user

	def initialize(client_arg)
		@client = client_arg
	end
end