class World
	@@last_time = nil
	@@current_time = nil
	@@tick_length = 10

	def self.update
		@@current_time = Time.now
		# @ticks = (@@current_time - @@last_time / @@tick_length).to_i

		while (true)
			sleep 15
			p "\n... tick tock ...\n"
		end

		@@last_time = Time.now
	end
end