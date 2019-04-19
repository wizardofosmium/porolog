#
#   test/test_helper.rb     - Test Suite Helper for Porolog
#
#     Luis Esteban      2 May 2018
#       created
#

require 'minitest/autorun'
require 'porolog'

include Porolog

def reset
  Scope.reset
end

def assert_scope(scope, name, predicates)
  assert_instance_of  Scope,            scope
  assert_equal        name,             scope.name
  assert_equal        predicates,       scope.predicates
end
