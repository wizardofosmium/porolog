#
#   test/test_helper.rb     - Test Suite Helper for Porolog
#
#     Luis Esteban      2 May 2018
#       created
#

# -- Test Coverage --
require 'simplecov'
SimpleCov.start

require 'shields_badge'
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::ShieldsBadge
])

# -- Testing --
require 'minitest/autorun'
require 'porolog'

include Porolog


# -- Helpers --
def reset
  Scope.reset
  Predicate.reset
  Arguments.reset
end

def assert_Scope(scope, name, predicates)
  assert_instance_of  Scope,            scope
  assert_equal        name,             scope.name
  assert_equal        predicates,       scope.predicates
end

def assert_Predicate(predicate, name, rules)
  assert_instance_of  Predicate,        predicate
  assert_equal        name,             predicate.name
  assert_equal        rules,            predicate.rules
end

def assert_Arguments(arguments, predicate, args)
  assert_instance_of  Arguments,        arguments
  assert_equal        predicate,        arguments.predicate.name
  assert_equal        args,             arguments.arguments
end
