require 'erb'
require 'colorize'

class View
	def self.render_template(template, args)
		path = VIEW_DIR + template + '.rb'
		@args = args
		if (File.exists? path)
			template = File.open(path).read
			erb = ERB.new(template)
			return erb.result(binding)
		end
	end
end