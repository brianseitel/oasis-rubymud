require 'socket'
require File.dirname(__FILE__) + '/interpreter'

class MudServer
	def self.socket
		@socket
	end

	def self.startup

		puts "Starting up server..."

		server = TCPServer.new(4000)

		while (@socket = server.accept)
			Thread.start do
				puts "log: Connection from #{@socket.peeraddr[2]} at #{@socket.peeraddr[3]}"
				puts "log: got input from client"

				while (@input = @socket.gets.chomp("\r\n"))
					@output = self.game_loop()
					@socket.puts @output
				end

				@socket.puts "Server: Welcome #{@socket.peeraddr[2]}\n"

				puts "log: sending goodbye"
				@socket.puts "Server: Goodbye\n"
			end  #end thread conversation
		end   #end loop
	end

	def self.game_loop()

		@output = Interpreter.interpret(@input);

		return @output;
	end
end

MudServer.startup()