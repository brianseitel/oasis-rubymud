require 'active_record'

class User < ActiveRecord::Base

	attr_accessor :username
	attr_accessor :room_id
	attr_accessor :area_id
	attr_accessor :password

	@room_id = 1
	
	def self.do_new(username)
		@input = ""
		while (@input.downcase != "y" && @input.downcase != "n")
			MudServer.socket.puts "Are you a new user? [y/n]\n"
			@input = MudServer.socket.gets.chomp("\r\n")
		end

		if (@input == "n")
			return false
		end

		# Choose a password
		@password = "."
		@confirm = ""

		while (@password != @confirm)
			MudServer.socket.puts "Choose a password:"
			@password = MudServer.socket.gets.chomp("\r\n")

			MudServer.socket.puts "Confirm your password"
			@confirm = MudServer.socket.gets.chomp("\r\n")
		end

		@user = User.create(username => username, password => @password, area_id => 1, room_id => 1)
		return @user
	end

	def self.login
		found = false
		while (!found)
			MudServer.socket.puts "What's your name?\n"
			@input = MudServer.socket.gets.chomp("\r\n")
			@user = User.find_by username: @input
			if (@user)
				MudServer.socket.puts "Enter password: "
				@password = MudServer.socket.gets.chomp("\r\n")
				@user = User.find_by username: @input, password: @password

				if (@user)
					found = true
				else
					MudServer.socket.puts "Invalid password.\n\n"
				end
			else
				@user = User.do_new
				if (@user)
					found = true
				end
			end
		end

		return @user
	end
end