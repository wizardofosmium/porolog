#
#   porolog.gemspec   - Gem specification file for Porolog
#
#     Luis Esteban    15 April 2019
#       created
#

require_relative 'lib/porolog'

Gem::Specification.new do |gem|
  # -- Attributes --
  gem.name                      = 'porolog'
  gem.summary                   = 'Prolog using Plain Old Ruby Objects'
  gem.description               = 'Implements a Prolog inference engine using Plain Old Ruby Objects'
  gem.authors                   = ['Luis Esteban']
  gem.version                   = Porolog::VERSION
  gem.date                      = Porolog::VERSION_DATE
  gem.license                   = 'Unlicense'
  gem.email                     = ['luis.esteban.consulting@gmail.com']
  gem.homepage                  = 'https://github.com/wizardofosmium/porolog'
  gem.default_executable        = 'porolog'
  gem.require_paths             = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 0') if gem.respond_to? :required_rubygems_version=
  
  # -- Files --
  gem.files = Dir[
    'README.md',
    'Rakefile',
    'bin/porolog',
    'lib/porolog.rb',
    'lib/porolog/*.rb',
    'lib/porolog/**/*.rb',
    'doc/**',
    'coverage/**',
  ]
  
  # -- Test Files --
  gem.test_files = Dir[
    'test/test_helper.rb',
    'test/**/*_test.rb',
  ]
end
