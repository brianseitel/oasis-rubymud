class Util
	
	def self.guess_objects(name, obj_list)
		results = []
		name = name.downcase
		obj_list.each do |item|
			len = name.length - 1

			keywords = item.name.split(" ")
			keywords.each do |obj_name|
				itemname = obj_name[0..len].downcase
				if (itemname == name)
					results << item
				end
			end
		end

		return results
	end

end