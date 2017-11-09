# -*- ruby -*-

require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler/gem_tasks'

$:.push File.expand_path(File.dirname(__FILE__), 'lib')

version = GD2::VERSION

desc 'Test GD2 interface'
Rake::TestTask.new(:test) do |t|
  t.libs << "#{File.dirname(__FILE__)}/test"
  t.test_files = FileList['test/**/*_tests.rb']
  t.verbose = !!ENV['VERBOSE_TESTS']
  t.warning = !!ENV['WARNINGS']
end

task :default => :test

desc 'Build docs'
Rake::RDocTask.new do |t|
  t.title = "gd2-ffij #{version}"
  t.main = 'README.rdoc'
  t.rdoc_dir = 'doc'
  t.rdoc_files.include('README.rdoc', 'COPYRIGHT', 'lib/**/*.rb')
end
