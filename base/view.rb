require 'erb'
require 'colorize'

class View
	def self.render_template(template, args)
		path = setting('view_dir') + template + '.rb'
		@args = args
		if (File.exists? path)
			template = File.open(path).read
			erb = ERB.new(template, nil, '-')
			return erb.result(binding)
		end
	end
end