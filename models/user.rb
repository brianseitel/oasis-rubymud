require 'active_record'

# 
# The User model that keeps track of everything a player does.
# 
# @author [brianseitel]
# 
class User < ActiveRecord::Base
	serialize :stats, JSON
	
	after_create :setup_new_character

	public
		# 
		# Display score screen, including name, race, class, gender, health, mana, stats, armor, etc
		# 
		def show_score
			output = []

			## Set the vars
			username 		= " #{self.username}"
			level 			= "Level #{self.level}"
			exp 			= "#{self.experience} XP "
			split 			= (40 - username.length - level.length - exp.length) / 2
			hitpoints 		= " Hitpoints: #{self.hit_points}/#{self.max_hit_points}"
			mana 			= "Mana: #{self.mana}/#{self.max_mana} "
				
			# Generate output
			output << username + " " * split + level + " " * split + exp
			output << "-" * 40
			output << hitpoints + " " * (40 - hitpoints.length - mana.length) + mana
			output << "-" * 40
			self.stats.each do |name, value|
				enhanced = self.enhanced_stats.values_at(name).first
				spaces = 40 - name.length - value.to_s.length - enhanced.to_s.length - 4
				output << " #{name}" + (" " * spaces) + "#{enhanced} (#{value}) "
			end
			output << "-" * 40

			# Display output to screen
			current_client.puts output.join("\n")
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