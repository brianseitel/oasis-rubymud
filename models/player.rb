require 'active_record'

# 
# The Player model that keeps track of everything a player does.
# 
# @author [brianseitel]
# 
class Player < ActiveRecord::Base
	attr_accessor :client

	serialize :stats, JSON
	after_create :setup_new_character

	public

		# 
		# Display score screen, including name, race, class, gender, health, mana, stats, armor, etc
		# 
		def show_score
			output = []

			## Set the vars
			tnl = ((self.level * 1000) - self.experience)
			params = {
				:name => self.name,
				:level => "Level #{self.level}",
				:tnl => "#{tnl} TNL",
				:stats => self.stats,
				:dashes => "-" * MAX_WIDTH
			}

			# Calculate distance between words at top of table
			params[:spaces1] = " " * ((MAX_WIDTH - params[:name].to_s.length - params[:level].to_s.length - params[:tnl].to_s.length) / 2).floor

			# Calculate the distance between stat and value on table
			splits = {}
			self.stats.each do |name, value|
				splits[name] = " " * (MAX_WIDTH - name.to_s.length - value.to_s.length)
			end
			params[:splits] = splits

			# output to socket
			current_client.puts "\n" + View.render_template('player.score', params) + "\n"
		end

		# 
		# Return enhanced stats
		# 
		def enhanced_stats
			self.stats
		end
		
		def gain_exp(victim)
			experience = victim.level * Random.rand(50) + Random.rand(100)
			if (current_player == self)
				current_client.puts "You have KILLED #{victim.name}!!\n"
				current_client.puts "You gain #{experience} experience points!"
			end
			self.experience += experience
			self.save
		end

		def is_dead
			if (self.hit_points <= 0)
				return true
			end
			return false
		end

		# 
		# Show a list of player's stats in a table format
		# 
		def show_stats
			output = []
			output << "Your Stats"
			output << "-" * 40
			self.stats.each do |name, value|
				enhanced = self.enhanced_stats.values_at(name).first
				spaces = 40 - name.length - value.to_s.length - enhanced.to_s.length - 4
				output << " #{name}" + (" " * spaces) + "#{enhanced} (#{value}) "
			end
			output << "-" * 40

			current_client.puts output.join("\n") + "\n"
		end

		# 
		# Show status prompt to the player.
		# 
		def show_status_prompt
			stats = {
				:hp => self.hit_points,
				:maxhp => self.max_hit_points,
				:mana => self.mana,
				:max_mana => self.max_mana,
				:tnl => (self.level * 1000) - self.experience
			}
			current_client.print "\n" + View.render_template('player.status_prompt', stats) + " "
		end

	private
		# 
		# Set up player with default values
		# 
		def setup_new_character
			self.stats = {
				'strength' => 12,
				'intelligence' => 12,
				'constitution' => 12,
				'dexterity' => 12,
				'wisdom' => 12,
				'charisma' => 12
			}
			self.hit_points = 100
			self.max_hit_points = 100
			self.mana = 100
			self.max_mana = 100
			self.level = 1
			self.experience = 0
			self.room_id = 1
			self.area_id = 1
			self.save
		end
end