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
  Instantiation.reset
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
  assert_instance_of  Goal,                       goal
  assert_equal        predicate,                  goal.arguments.predicate.name
  assert_equal        goal.variablise(arguments), goal.arguments.arguments
  # TODO: add definition
  #assert_equal        definition,       goal.definition
end

def assert_Goal_variables(goal, hash, str)
  assert_instance_of  Goal,             goal
  assert_equal        hash,             goal.variables
  assert_equal        str,              goal.inspect_variables
end

def assert_Value(value, value_value, goal)
  assert_instance_of  Value,            value
  assert_equal        value_value,      value.value
  assert_equal        goal,             value.goal
end

def assert_Variable(variable, name, goal, instantiations, values)
  assert_instance_of  Variable,         variable
  assert_equal        name,             variable.name
  assert_equal        goal,             variable.goal
  assert_equal        instantiations,   variable.instantiations
  assert_equal        values,           variable.values
end

def assert_Instantiation(instantiation, variable1, variable2, index1, index2)
  assert_instance_of  Instantiation,    instantiation
  assert_includes     [Variable,Value], variable1.class
  assert_includes     [Variable,Value], variable2.class
  assert_equal        variable1,        instantiation.variable1
  assert_equal        variable2,        instantiation.variable2
  if index1
    assert_equal      index1,           instantiation.index1
  else
    assert_nil                          instantiation.index1
  end
  if index2
    assert_equal      index2,           instantiation.index2
  else
    assert_nil                          instantiation.index2
  end
end

def assert_Tail(tail, inspect)
  assert_instance_of  Tail,             tail
  assert_equal        inspect,          tail.inspect
end

def assert_Array_with_Tail(array, head, inspect)
  assert_instance_of  Array,            array
  assert_equal        head.size + 1,    array.size
  assert_equal        head,             array[0...head.size]
  assert_Tail         array.last,       inspect
end

def expect_unify_arrays_with_calls(no_tails, some_tails, all_tails)
  expects(:unify_arrays_with_no_tails  ).times(no_tails)
  expects(:unify_arrays_with_some_tails).times(some_tails)
  expects(:unify_arrays_with_all_tails ).times(all_tails)
end

def assert_Unify_arrays(arrays, goals, merged, unifications = [])
  result_merged, result_unifications = unify_arrays(*arrays, *goals)
  
  unifications = unifications.map{|v1,v2,g1,g2|
    assert_instance_of  Goal, g1
    assert_instance_of  Goal, g2
    [g1.variablise(v1), g2.variablise(v2), g1, g2]
  }
  
  assert_equal    merged,          result_merged
  assert_equal    unifications,    result_unifications
end

def refute_Unify_arrays(arrays, goals, log = [])
  result = unify_arrays(*arrays, *goals)
  
  assert_nil      result
  
  goals.each do |goal|
    assert_equal    log,            goal.log
  end
end


def new_goal(predicate_name, *arguments_list)
  predicate = Predicate.new(predicate_name)
  arguments = predicate.arguments(*arguments_list)
  arguments.goal
end
