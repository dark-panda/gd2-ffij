# -*- encoding: utf-8 -*-

require File.expand_path('../lib/gd2/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['J Smith']
  gem.email         = ['dark.panda@gmail.com']

  gem.description   = 'gd2-ffij is a Ruby/GD2 library'
  gem.summary       = 'gd2-ffij is a refactoring of the Ruby/GD2' \
                      'library implemented with FFI'

  gem.homepage      = 'https://github.com/dark-panda/gd2-ffij'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "gd2-ffij"

  gem.require_paths = ["lib"]

  gem.version       = GD2::VERSION

  gem.add_dependency('ffi', '~> 1.0.0')
end
