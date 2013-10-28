require 'active_record'

# 
# The User model that keeps track of everything a player does.
# 
# @author [brianseitel]
# 
class User < ActiveRecord::Base

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
				@user = User.do_new(@input)
				if (@user)
					found = true
				end
			end
		end
		return @user
	end
end