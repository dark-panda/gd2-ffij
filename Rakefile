# -*- ruby -*-

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

$:.push 'lib'

begin
	require 'jeweler'
	Jeweler::Tasks.new do |gem|
		gem.name        = "gd2-ffij"
		gem.version     = "0.0.3"
		gem.summary     = "gd2-ffij is a refactoring of the Ruby/GD2 library implemented with FFI"
		gem.description = "gd2-ffij is a refactoring of the Ruby/GD2 library implemented with FFI"
		gem.email       = "dark.panda@gmail.com"
		gem.homepage    = "http://github.com/dark-panda/gd2-ffij"
		gem.authors =    [ "J Smith" ]
		# gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
	end
	Jeweler::GemcutterTasks.new
rescue LoadError
	puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc 'Test GD2 interface'
Rake::TestTask.new(:test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/*_test.rb'
	t.verbose = false
end

