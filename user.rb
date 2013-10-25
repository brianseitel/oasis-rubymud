class User
	attr_accessor :name
	attr_accessor :room_id

	@room_id = 1
	
	def initialize(name)
		@name = name
	end
end