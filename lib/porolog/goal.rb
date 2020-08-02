#
#   lib/porolog/goal.rb      - Plain Old Ruby Objects Prolog Engine -- Goal
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Goal finds solutions for specific Arguments of a Predicate.
  #
  # @author Luis Esteban
  #
  # @!attribute calling_goal
  #   @return [Porolog::Goal, nil] The parent goal if this goal is a subgoal, otherwise nil.
  # @!attribute arguments
  #   @return [Porolog::Arguments] The specific Arguments this goal is trying to solve.
  # @!attribute index
  #   @return [Integer, nil] Solution index for builtin predicates.
  # @!attribute result
  #   @return [Boolean] Whether any result has been found.
  # @!attribute description
  #   @return [String] Description of the Arguments the Goal is attempting to solve.
  # @!attribute log
  #   @return [Array<String>] Log of events, namely unification failures.
  #
  class Goal
    
    # Error class for rescuing or detecting any Goal error.
    class Error             < PorologError ; end
    # Error class indicating an unexpected type of Rule definition.
    class DefinitionError   < Error        ; end
    # Error class indicating a non-Variable was attempted to be instantiated.
    class NotVariableError  < Error        ; end
    
    # Clears all goals and ensures they are deleted.
    # @return [Boolean] success
    def self.reset
      @@goals ||= []
      goals = @@goals
      @@goals = []
      @@goal_count = 0
      goals.map(&:deleted?)
      true
    end
    
    # @return [Integer] the number of goals created
    def self.goal_count
      @@goal_count
    end
    
    reset
    
    attr_accessor :calling_goal, :arguments, :index, :result, :description, :log
    
    # Initializes and registers the Goal.
    # @param arguments [Porolog::Arguments] the Predicate Arguments that this Goal is to solve.
    # @param calling_goal [Porolog::Goal] the parent Goal if this Goal is a subgoal.
    def initialize(arguments, calling_goal = nil)
      @@goals << self
      @@goal_count += 1
      
      @arguments    = arguments
      @terminate    = false
      @calling_goal = calling_goal
      @variables    = {}
      @values       = {}
      @result       = nil
      @description  = "Solve #{arguments.inspect}"
      @log          = []
      
      @arguments = @arguments.dup(self) if @arguments.is_a?(Arguments)
      @solutions = []
    end
    
    # @return [Array<Porolog::Goal>] the calling chain for this goal.
    def ancestors
      ancestors = []
      goal      = self
      
      while goal
        ancestors << goal
        goal = goal.calling_goal
      end
      
      ancestors.reverse
    end
    
    # A convenience method for testing/debugging.
    # @return [String] the calling chain for this goal as a String.
    def ancestry
      indent = -1
      ancestors.map do |goal|
        indent += 1
        "#{'  ' * indent}#{goal.myid} -- #{goal.description}  #{goal.variables.inspect}"
      end.join("\n")
    end
    
    # A convenience method for testing/debugging.
    # @return [String] the id of the goal.
    def myid
      "Goal#{(@@goals.index(self) || -1000) + 1}"
    end
    
    # @return [String] pretty representation.
    def inspect
      "#{myid} -- #{description}"
    end
    
    # A convenience method for testing/debugging.
    # @return [Array<Porolog::Goal>]
    def self.goals
      @@goals
    end
    
    # Delete the Goal
    # @return [Boolean] whether the Goal has been deleted (memoized)
    def delete!
      @@goals.delete(self)
      deleted?
    end
    
    # @return [Boolean] whether the Goal has been deleted (memoized)
    def deleted?
      @deleted ||= check_deleted
      @deleted
    end
    
    # Determines whether the Goal has been deleted and removes its Variables and Values if it has.
    # @return [Boolean] whether the Goal has been deleted
    def check_deleted
      return false if @@goals.include?(self)
      
      @variables.delete_if do |_name,variable|
        variable.remove
        true
      end
      
      @values.delete_if do |_name,value|
        value.remove
        true
      end
      
      true
    end
    
    # Sets that the goal should no longer search any further rules for the current predicate
    # once the current rule has finished being evaluated.
    # This method implements the :CUT rule.
    # That is, backtracking does not go back past the point of the cut.
    # @return [Boolean] true.
    def terminate!
      @log << 'terminating'
      @terminate = true
    end
    
    # @return [Boolean] whether the goal has been cut.
    def terminated?
      @terminate
    end
    
    # Converts all embedded Symbols to Variables within this Goal.
    # @param object [Object] the object to variablise.
    # @return [Object] the variablised object.
    def variablise(object)
      case object
        when Symbol,Variable
          variable(object)
        when Array
          object.map{|element| variablise(element) }
        when Arguments
          object.dup(self)
        when Tail
          Tail.new variablise(object.value)
        when Value
          object
        when NilClass
          nil
        else
          if [UNKNOWN_TAIL, UNKNOWN_ARRAY].include?(object)
            object
          else
            value(object)
          end
      end
    end
    
    alias [] variablise
    
    # @return [Hash{Symbol => Object}] the Variables and their current values of this Goal
    def variables
      @variables.keys.each_with_object({}){|variable,variable_list|
        value = value_of(variable).value.value
        if value.is_a?(Variable)
          variable_list[variable] = nil
        elsif value.is_a?(Array)
          variable_list[variable] = value.clean
        else
          variable_list[variable] = value
        end
      }
    end
    
    # A convenience method for testing/debugging.
    # @return [String] a tree representation of all the instantiations of this goal's variables.
    def inspect_variables
      @variables.values.map(&:inspect_with_instantiations).join("\n")
    end
    
    # A convenience method for testing/debugging.
    # @return [Array<Object>] the values instantiated for this goal.
    def values
      @values.values.map(&:value)
    end
    
    # Finds or tries to create a variable in the goal (as much as possible) otherwise passes the parameter back.
    # @param name [Object] name of variable or variable
    # @return [Porolog::Variable, Object] a variable of the goal or the original parameter
    def variable(name)
      return name unless name.is_a?(Symbol) || name.is_a?(Variable)
      
      if name.is_a?(Variable)
        variable = name
        @variables[variable.name] = variable if variable.goal == self
        return variable
      end
      
      @variables[name] ||= (name.is_a?(Variable) && name || Variable.new(name, self))
      @variables[name]
    end
    
    # @param value [Object] the value that needs to be associated with this Goal.
    # @return [Porolog::Value] a Value, ensuring it has been associated with this Goal so that it can be uninstantiated.
    def value(value)
      @values[value] ||= Value.new(value, self)
      @values[value]
    end
    
    # Returns the value of the indicated variable or value
    # @param name [Symbol, Object] name of the variable or value
    # @param index [Object] index is not yet used
    # @param visited [Array] used to avoid infinite recursion
    # @return [Object] the value
    def value_of(name, index = nil, visited = [])
      variable(name).value(visited)
    end
    
    # Returns the values of an Object.  For most objects, this will basically just be the object.
    # For Arrays, an Array will be returned where the elements are the value of the elements.
    # @param object [Object] the Object to find the values of.
    # @return [Object,Array<Object>] the value(s) of the object.
    def values_of(object)
      case object
        when Array
          object.map{|element| values_of(element) }
        when Variable,Symbol,Value
          value_of(object)
        when Tail
          # TODO: This needs to splat outwards; in the meantime, it splats just the first.
          value_of(object.value).first
        else
          object
      end
    end
    
    # Finds all possible solutions to the Predicate for the specific Arguments.
    # @param max_solutions [Integer] if provided, the search is stopped once the number of solutions has been found
    # @return [Array<Hash{Symbol => Object}>]
    def solve(max_solutions = nil)
      return @solutions unless @arguments
      
      predicate = @arguments.predicate
      
      predicate&.satisfy(self) do |goal|
        # TODO: Refactor to overrideable method (or another solution, say a lambda)
        
        @solutions << variables
        @log << "SOLUTION: #{variables}"
        @log << goal.ancestry
        @log << goal.inspect_variables
        
        return @solutions if max_solutions && @solutions.size >= max_solutions
      end
      
      @solutions
    end
    
    # Solves the goal but not as the root goal for a query.
    # That is, solves an intermediate goal.
    # @param block [Proc] code to perform when the Goal is satisfied.
    # @return [Boolean] whether the definition was satisfied.
    def satisfy(&block)
      return false unless @arguments
      
      predicate = @arguments.predicate
      
      satisfied = false
      predicate&.satisfy(self) do |subgoal|
        subgoal_satisfied = block.call(subgoal)
        satisfied ||= subgoal_satisfied
      end
      satisfied
    end
    
    # Instantiates a Variable to another Variable or Value, for this Goal.
    # @param name [Symbol,Porolog::Variable,Object] the name that references the variable to be instantiated.
    # @param other [Object] the value that the variable is to be instantiated to.
    # @param other_goal [Porolog::Goal,nil] the Goal of the other value.
    # @return [Porolog::Instantiation] the instantiation.
    def instantiate(name, other, other_goal = self)
      variable = self.variable(name)
      
      other = if other.type == :variable
        other_goal.variable(other)
      else
        other_goal.value(other)
      end
      
      variable.instantiate(other)
    end
    
    # Inherits variables and their instantiations from another goal.
    # @param other_goal [Porolog::Goal,nil] the Goal to inherit variables from.
    # @return [Boolean] whether the variables could be inherited (unified).
    def inherit_variables(other_goal = @calling_goal)
      return true unless other_goal
      
      unified      = true
      unifications = []
      variables    = (
        other_goal.arguments.variables +
        other_goal.variables.keys +
        self.arguments.variables
      ).map(&:to_sym).uniq
      
      variables.each do |variable|
        name = variable
        
        unification = unify(name, name, other_goal, self)
        unified   &&= !!unification
        if unified
          unifications += unification
        else
          #:nocov:
          self.log << "Couldn't unify: #{name.inspect} WITH #{other_goal.myid} AND #{self.myid}"
          break
          #:nocov:
        end
      end
      unified &&= instantiate_unifications(unifications) if unified
      
      unified
    end
    
  end
  
end
