# -*- ruby -*-

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

$:.push 'lib'
require 'gd2-jay'

PKG_NAME    = 'gd2-jay'
PKG_VERSION = GD2::VERSION

spec = Gem::Specification.new do |s|
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = 'Ruby interface to the GD2 library via FFI.'

  s.files             = FileList['README', 'COPY*', 'Rakefile', 'lib/**/*.rb']
  s.autorequire       = 'gd2-jay'
  s.requirements     << 'libgd, v2.0.33 or greater'
  s.test_files        = FileList['test/*.rb']

  s.has_rdoc          = true
  s.rdoc_options     << '--title' << 'Ruby/GD2' << '--charset' << 'utf-8'
  s.extra_rdoc_files  = FileList['README', 'COPYING']

  s.author            = 'J Smith'
  s.email             = 'dark.panda@gmail.com'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc 'Test GD2 interface'
Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
end

