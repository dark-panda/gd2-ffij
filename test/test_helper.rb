# frozen_string_literal: true; encoding: ASCII-8BIT

if RUBY_VERSION >= '1.9'
  require 'simplecov'

  SimpleCov.command_name('Unit Tests')
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'tmpdir'

require 'rubygems'
require 'gd2-ffij'
require 'minitest/autorun'

if RUBY_VERSION >= '1.9'
  require 'minitest/reporters'
end

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
end

if RUBY_VERSION >= '1.9'
  MiniTest::Reporters.use!(MiniTest::Reporters::SpecReporter.new)
end

