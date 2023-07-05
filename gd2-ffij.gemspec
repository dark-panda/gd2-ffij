# frozen_string_literal: true

require File.expand_path('lib/gd2/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'gd2-ffij'
  s.version = GD2::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 2.5'
  s.authors = ['J Smith']
  s.description = 'gd2-ffij is a refactoring of the Ruby/GD2 library implemented with FFI'
  s.summary = s.description
  s.email = 'dark.panda@gmail.com'
  s.license = 'MIT'
  s.extra_rdoc_files = ['README.rdoc']
  s.files = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.homepage = 'http://github.com/dark-panda/gd2-ffij'
  s.require_paths = ['lib']

  s.add_dependency('ffi', ['>= 1.0.0'])
  s.add_dependency('matrix')
end
