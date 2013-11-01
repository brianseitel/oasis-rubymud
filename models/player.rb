require 'active_record'

# 
# The Player model that keeps track of everything a player does.
# 
# @author [brianseitel]
# 
class Player < ActiveRecord::Base
	attr_accessor :client
	attr_accessor :state # Whether they're fighting, standing, dead, etc.

	STATE_DEAD 		= 0
	STATE_STANDING 	= 1
	STATE_FIGHTING 	= 2
	STATE_SLEEPING 	= 3

	serialize :stats, JSON
	after_create :setup_new_character

	public

		def die
			if (MudServer.logged_in? self)
				self.hit_points = 1
				self.mana = 1

				# take a hit in XP for dying. 1/2 of TNL usually.
				tnl = Level.til_next self

				self.experience -= tnl / 2
				self.save

				self.state = STATE_DEAD

				self.goto_room(1)
			end
		end

		def is_dead?
			return self.state == STATE_DEAD
		end

		def goto_room(room)
			if (!room.instance_of? Room)
				room = Room.find(room)
			end

			player = MudServer.get_player self
			player.room_id = room.id
			player.save
			
			room.broadcast "#{self.name} appears in a ray of light from the sky.\n"
			Room.display room
		end
		# 
		# Display score screen, including name, race, class, gender, health, mana, stats, armor, etc
		# 
		def show_score
			output = []

			## Set the vars
			tnl = Level.til_next self
			params = {
				:name => self.name,
				:level => "Level #{self.level}",
				:tnl => "#{tnl} TNL",
				:stats => self.stats,
				:dashes => "-" * setting('max_width')
			}

			# Calculate distance between words at top of table
			params[:spaces1] = " " * ((setting('max_width') - params[:name].to_s.length - params[:level].to_s.length - params[:tnl].to_s.length) / 2).floor

			# Calculate the distance between stat and value on table
			splits = {}
			self.stats.each do |name, value|
				splits[name] = " " * (setting('max_width') - name.to_s.length - value.to_s.length)
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

		def is_dead
			if (self.hit_points <= 0)
				return true
			end
			return false
		end

		def recover_health
			percentage = Random.rand(5..15)
			increase = (percentage.to_f / 100.0).to_f
			hp = self.max_hit_points
			new_hp = self.hit_points + (hp * increase)
			self.hit_points = [new_hp, self.max_hit_points].min
			self.save
		end

		def recover_mana
			percentage = (Random.rand(5..15).to_f / 100.0)
			mana = self.max_mana
			new_mana = self.mana + (mana * percentage)
			self.mana = [new_mana, self.max_mana].min
			self.save
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
			p = MudServer.get_player self
			if (p)
				p.client.print "\n" + View.render_template('player.status_prompt', stats) + " "
			end
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

			self.state = self.STATE_STANDING
		end
end