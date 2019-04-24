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
require 'mocha/minitest'
require 'spy/integration'
require 'porolog'

include Porolog


# -- Helpers --
def reset
  Scope.reset
  Predicate.reset
  Arguments.reset
  Rule.reset
  Goal.reset
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

def assert_Rule(rule, predicate, arguments, definition)
  assert_instance_of  Rule,             rule
  assert_equal        predicate,        rule.arguments.predicate.name
  assert_equal        arguments,        rule.arguments.arguments
  assert_equal        definition,       rule.definition
end

def assert_Goal(goal, predicate, arguments)#, definition)
  assert_instance_of  Goal,             goal
  assert_equal        predicate,        goal.arguments.predicate.name
  assert_equal        arguments,        goal.arguments.arguments
  # TODO: add definition
  #assert_equal        definition,       goal.definition
end

def assert_Goal_variables(goal, hash, str)
  assert_instance_of  Goal,             goal
  assert_equal        hash,             goal.variables
  # TODO: add inspect_variables
  #assert_equal        str,              goal.inspect_variables
end


def new_goal(predicate_name, *arguments_list)
  predicate = Predicate.new(predicate_name)
  arguments = predicate.arguments(*arguments_list)
  arguments.goal
end
