require 'rubygems'
require 'bundler/setup'
require 'socket'


require File.dirname(__FILE__) + '/interpreter'
require File.dirname(__FILE__) + '/area'
require File.dirname(__FILE__) + '/user'
require File.dirname(__FILE__) + '/db'
require File.dirname(__FILE__) + '/world'

Logger::new(STDOUT)

def current_thread
	return Thread.current[:connection]
end

def current_client
	return current_thread.client
end

def current_user
	return current_thread.user
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
					end
				end

				client.puts "\nWelcome, #{@user.username}!\n"

				self.game_loop
			end

			Thread.start do
				World.update
			end

		end
	end

	def self.game_loop()
		input = nil
		world = nil

		Area.display_room

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

MudServer.startup