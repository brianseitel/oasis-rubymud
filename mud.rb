require 'rubygems'
require 'bundler/setup'
require 'socket'
require File.dirname(__FILE__) + '/interpreter'
require File.dirname(__FILE__) + '/user'
require File.dirname(__FILE__) + '/db'
require File.dirname(__FILE__) + '/world'

class MudServer
	attr_accessor :sockets
	$sockets = {}
	@@game_over = false

	def sockets
		$sockets
	end

	def self.socket
		@socket
	end

	def self.startup
		puts "Starting up server..."

		server = TCPServer.new(4000)

		while (@socket = server.accept)
			connection = Connection.new(@socket)
			$sockets[@socket] = connection
			Thread.start do
				puts "log: Connection from #{@socket.peeraddr[2]} at #{@socket.peeraddr[3]}"
				puts "log: got input from client"

				# show welcome
				self.show_welcome

				while (!connection.user)
					@user = User.login

					if (@user)
						connection.user = @user
					end
				end

				@socket.puts "\nWelcome, #{@user['username']}!\n"

				self.game_loop()

				@socket.puts "Server: Welcome #{@socket.peeraddr[2]}\n"

				puts "log: sending goodbye"
				@socket.puts "Server: Goodbye\n"
			end

			Thread.start do
				World.update
			end
		end
	end

	def self.game_loop()
		input = nil
		world = nil
		begin
			while (!@@game_over)
				# Wait for input
				if (!input)
					input = Thread.new(self.await_input)
				end
			end
		rescue Exception => e
			pp e
		end
	end

	def self.await_input
		while (@input = @socket.gets.chomp("\r\n"))
			@output = Interpreter.interpret(@input);
			@socket.puts @output
		end
	end


	def self.login()
		@output = "Enter your name:"
		return @output
	end

	def self.show_welcome
		self.socket.puts "\n\n**** Welcome to Oasis! ***\n\n"
	end
end

class Connection
	attr_accessor :socket
	attr_accessor :user

	def initialize(socket_arg)
		@socket = socket_arg
	end
end

MudServer.startup