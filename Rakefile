# -*- ruby -*-

require 'rubygems'
require 'rake/gempackagetask'

$:.push 'lib'
require 'gd2'

PKG_NAME    = 'gd2'
PKG_VERSION = GD2::VERSION

spec = Gem::Specification.new do |s|
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = 'Ruby interface to gd 2 library.'

  s.files             = FileList['README', 'COPY*', 'Rakefile', 'lib/**/*.rb']
  s.autorequire       = 'gd2'
  s.requirements     << 'libgd, v2.0.33 or greater'
  s.test_files        = FileList['test/*.rb']

  s.has_rdoc          = true
  s.rdoc_options     << '--title' << 'Ruby/GD2' << '--charset' << 'utf-8'
  s.extra_rdoc_files  = FileList['README', 'COPYING']

  s.author            = 'Rob Leslie'
  s.email             = 'rob@mars.org'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
