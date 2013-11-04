class Magic

	def self.do_cast(args)
		spell = args[0]
		target = args[1].nil? ? nil : args[1]

		s = "spell_#{spell}"
		if (self.respond_to? s)
			self.send(s, target)
		else
			current_client.puts "You mumble gibberish -- but nothing happens!"
		end
	end

	def self.spell_heal(target)
		mana_cost = 10
		if (target.nil?)
			player = current_player
		else
			player = MudServer.get_player(target)
		end
		
		if (current_player.mana < mana_cost)
			current_client.puts "You don't have enough mana!"
			return
		end

		max_amount = (player.max_hit_points * (Random.rand(0..35).to_f / 100.0)).to_i
		heal_amount = Random.rand(0..max_amount)

		if (player.hit_points + heal_amount > player.max_hit_points)
			heal_amount = player.max_hit_points - player.hit_points
		end

		if (heal_amount == 0)
			current_client.puts "You are already healed!"
		else
			current_client.puts "You cast 'heal' and recover #{heal_amount} hit points."
			player.hit_points += heal_amount
			player.mana -= mana_cost
			player.save
		end
	end
end