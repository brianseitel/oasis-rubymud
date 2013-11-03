class Inventory
	attr_accessor :data

	def to_json
		return @data
	end

	def initialize(data)
		@data = data
	end

	def add(item)
		data = {}
		item.attributes.each do |key, value|
			data[key] = value
		end	
		@data[@data.length] = data
	end

	def drop(item)
		n = 0
		@data.each do |i|
			dropee = Item.load_data(i)
			if (item == dropee)
				@data.delete_at n
				return
			end
			n += 1
		end
	end

	def all
		results = []
		@data.each do |item|
			results << Item.load_data(item)
		end	
		return results
	end
end