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
  gem.homepage                  = 'http://rubygems.org/gems/porolog'
  gem.default_executable        = 'porolog'
  gem.require_paths             = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 0') if gem.respond_to? :required_rubygems_version=
  gem.rubygems_version          = '1.6.2'
  
  # -- Files --
  gem.files = Dir[
    'README.md',
    'Rakefile',
    'lib/porolog.rb',
    'bin/porolog',
    'lib/porolog/*.rb',
  ]
  
  # -- Test Files --
  gem.test_files = Dir[
    'test/test_helper.rb',
    'test/porolog/*_test.rb',
  ]
end
