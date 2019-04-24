#
#   lib/porolog/goal.rb      - Plain Old Ruby Objects Prolog Engine -- Goal
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Goal finds solutions for specific Arguments of a Predicate.
  # @author Luis Esteban
  # @!attribute calling_goal
  #   @return [Porolog::Goal] The parent goal if this goal is a subgoal.
  # @!attribute arguments
  #   @return [Porolog::Arguments] The specific Arguments this goal is trying to solve.
  # @!attribute terminate
  #   @return [Boolean] Whether this Goal is to terminate.
  # @!attribute index
  #   @return [Integer, NilClass] Solution index for builtin predicates.
  # @!attribute result
  #   @return [Boolean] Whether any result has been found.
  class Goal
    
    # Error class for rescuing or detecting any Goal error.
    class GoalError        < PorologError ; end
    # Error class indicating an unexpected type of Rule definition.
    class DefinitionError  < GoalError    ; end
    # Error class indicating a non-Variable was attempted to be instantiated.
    class NotVariableError < GoalError    ; end
    
    # Clears all goals and ensures they are deleted.
    # @return [true]
    def self.reset
      @@goals ||= []
      goals = @@goals
      @@goals = []
      goals.map(&:deleted?)
      @@cache = {}
      true
    end
    
    reset
    
    attr_accessor :calling_goal, :arguments, :terminate, :index, :result
    
    # Initializes and registers the Goal.
    # @param arguments [Porolog::Arguments] the Predicate Arguments that this Goal is to solve.
    # @param calling_goal [Porolog::Goal] the parent Goal if this Goal is a subgoal.
    def initialize(arguments, calling_goal = nil)
      @arguments    = arguments
      @terminate    = false
      @calling_goal = calling_goal
      @variables    = {}
      @result       = false
      
      @arguments = @arguments.dup(self) if @arguments.is_a?(Arguments)
      
      @@goals << self
    end
    
    # A convenience method for testing/debugging.
    # @return [Array<Porolog::Goal>]
    def self.goals
      @@goals
    end
    
    # @return [Boolean] whether the Goal has been deleted (memoized)
    def deleted?
      @deleted ||= check_deleted
      @deleted
    end
    
    # Determines whether the Goal has been deleted and removes its Variables if it has
    # @return [Boolean] whether the Goal has been deleted
    def check_deleted
      if @@goals.include?(self)
        false
      else
        @variables.delete_if do |name,variable|
          variable.remove
          true
        end
        true
      end
    end
    
    # @return [Hash{Symbol => Object}] the Variables and their current values of this Goal
    def variables
      @variables.keys.each_with_object({}){|variable,variable_list|
        next if self.variable(variable).internal?
        variable_list[variable] = self.value_of(variable)
      }
    end
    
    # Finds or tries to create a variable in the goal (as much as possible) otherwise passes the parameter back.
    # @param name [Object] name of variable or variable
    # @return [Porolog::Variable, Object] a variable of the goal or the original parameter
    def variable(name)
      unless name.is_a?(Symbol) || name.is_a?(Variable)
        # -- Return parameter if it is not a variable --
        return name
      end
      
      if name.is_a?(Variable)
        variable = name
        @variables[variable.name] = variable if variable.goal == self
        return variable
      end
      
      @variables[name] ||= (name.is_a?(Variable) && name || Variable.new(name, self))
      @variables[name]
    end
    
    # Returns the value of the indicated variable or value
    # @param name [Symbol, Object] name of the variable or value
    # @param _index [Object] index is not used, it is for polymorphic compatibility with other classes
    # @param visited [Array] used to avoid infinite recursion
    # @return [Object] the value
    def value_of(name, _index = nil, visited = [])
      if name.is_a?(Symbol)
        variable = @variables[name]
        value    = variable && variable.value(visited) || self.variable(name)
      else
        value = name
      end
      
      if value.respond_to?(:value)
        begin
          value = value.value(visited)
        rescue
          return value
        end
      end
      
      value
    end
    
    # Finds all possible solutions to the Predicate for the specific Arguments.
    # @param number_of_solutions [Integer] if provided, the search is stopped once the number of solutions has been found
    # @return [Array<Hash{Symbol => Object}>]
    def solve(number_of_solutions = nil)
      solutions = []
      variables = @arguments.variables
      
      external_variables = variables.reject{|variable|
        self.variable(variable).internal?
      }
      
      satisfy do |goal|
        @result = true
        solution = {}
        
        external_variables.each{|variable|
          solution[variable.to_sym] = goal.value_of(variable)
        }
        
        solutions << solution
        
        if number_of_solutions && solutions.length >= number_of_solutions
          @solutions = solutions
          return @solutions
        end
      end
      
      # TODO: Delete all descendent goals
      
      @solutions = solutions
    end
    
  end
  
end
