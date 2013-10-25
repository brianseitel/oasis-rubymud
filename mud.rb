require 'socket'
require File.dirname(__FILE__) + '/interpreter'
require File.dirname(__FILE__) + '/user'

class MudServer
	attr_accessor :sockets
	$sockets = {}

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

				while (!connection.user)
					@socket.puts "What's your name?\n"
					@input = @socket.gets.chomp("\r\n")

					@user = User.new(@input)
					if (@user.name)
						connection.user = @user
					end
				end

				@socket.puts "\nWelcome, #{@user.name}!\n"

				while (@input = @socket.gets.chomp("\r\n"))
					@output = self.game_loop()
					@socket.puts @output
				end

				@socket.puts "Server: Welcome #{@socket.peeraddr[2]}\n"

				puts "log: sending goodbye"
				@socket.puts "Server: Goodbye\n"
			end
		end
	end

	def self.game_loop()
		@output = Interpreter.interpret(@input);
		return @output;
	end

	def self.login()
		@output = "Enter your name:"
		return @output
	end
end

class Connection
	attr_accessor :socket
	attr_accessor :user

	def initialize(socket_arg)
		@socket = socket_arg
	end

	def user=(user_arg)
		@user = user_arg
	end
end

MudServer.startup()