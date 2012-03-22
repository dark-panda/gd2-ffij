# -*- ruby -*-

require 'rubygems'

require 'rake/testtask'
require 'rdoc/task'

if RUBY_VERSION >= '1.9'
  begin
    gem 'psych'
  rescue Exception => e
    # it's okay, fall back on the bundled psych
  end
end

$:.push 'lib'

task :default => :test

require 'gd2/version'

desc 'Test GD2 interface'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_tests.rb']
  t.verbose = !!ENV['VERBOSE_TESTS']
end

desc 'Build docs'
Rake::RDocTask.new do |t|
  require 'rdoc'
  t.title = "gd2-ffij #{GD2::VERSION}"
  t.main = 'README'
  t.rdoc_dir = 'doc'
  t.rdoc_files.include('README', 'COPYING', 'COPYRIGHT', 'lib/**/*.rb')
end
