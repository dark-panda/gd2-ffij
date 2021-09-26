# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name('Unit Tests')
SimpleCov.start do
  add_filter '/test/'
end

require 'tmpdir'

require 'rubygems'
require 'gd2-ffij'
require 'minitest/autorun'
require 'minitest/reporters'

puts "Ruby version #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} - #{RbConfig::CONFIG['RUBY_INSTALL_NAME']}"
puts "ffi version #{Gem.loaded_specs['ffi'].version}" if Gem.loaded_specs['ffi']
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

  # Return a list of row coordinates in image that contain at least
  # one pixel with of the given colour.
  def rows_with_color(image, color)
    rows = []

    (0..image.height - 1).each do |y|
      (0..image.width - 1).each do |x|
        if image[x, y] == color
          rows.push y
          break
        end
      end
    end

    rows
  end
end

MiniTest::Reporters.use!(MiniTest::Reporters::SpecReporter.new)
