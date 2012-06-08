
require 'test/unit'
require 'tmpdir'

require 'rubygems'
require 'gd2-ffij'

puts "GD2 version: #{GD2::VERSION}"

module TestHelper
	PATH_TO_IMAGES = File.join(File.dirname(__FILE__), 'images')
	PATH_TO_FONT   = File.join(File.dirname(__FILE__), '..', 'vendor', 'fonts', 'ttf', 'DejaVuSans.ttf')

	def new_image
	    GD2::Image.new(256, 256)
	end

	def load_image(file_name)
	    GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, file_name)))
	end
end
