#
#   lib/porolog/rule.rb      - Plain Old Ruby Objects Prolog Engine -- Rule
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Rule is one clause of a Porolog::Predicate.
  #
  # @author Luis Esteban
  #
  # @!attribute [r] arguments
  #   The Arguments of the Predicate for which this Rule applies.
  # @!attribute [r] definition
  #   The definition of the Rule.
  #
  class Rule
    
    # Error class for rescuing or detecting any Rule error.
    class Error           < PorologError ; end
    # Error class indicating that there is an error in the definition of the Rule.
    class DefinitionError < Error        ; end
    
    attr_reader :arguments, :definition
    
    # Clears all Rules.
    # @return [Boolean] success
    def self.reset
      @@rules = []
      true
    end
    
    reset
    
    # Initializes the Rule.
    # @param arguments [Porolog::Arguments] the Arguments of the Predicate for which this Rule applies.
    # @param definition [Object] the definition of the Rule.
    def initialize(arguments, definition = nil)
      @arguments  = arguments
      @definition = definition
      @@rules << self
    end
    
    # Convenience method for testing/debugging
    # @return [String] pretty identification
    def myid
      "Rule#{(@@rules.index(self) || -1000) + 1}"
    end
    
    # @return [String] pretty representation.
    def inspect
      "  #{@arguments.inspect}:- #{@definition.inspect}"
    end
    
    # Try to satisfy the Rule for the given Goal.
    # @param goal [Porolog::Goal] the Goal in which to satisfy this Rule.
    # @param block [Proc] code to perform when the Rule is satisfied.
    # @return [Boolean] the success of deleting the subgoal.
    def satisfy(goal, &block)
      subgoal = Goal.new self.arguments, goal
      
      unified_goals = unify_goals(goal, subgoal)
      if unified_goals
        satisfy_definition(goal, subgoal) do |solution_goal|
          block.call(solution_goal)
        end
      else
        subgoal.log << "Dead-end: Cannot unify with #{goal.inspect}"
      end
      
      subgoal.delete!
    end
    
    # Try to satisfy the definition of the Rule for a given Goal.
    # @param goal [Porolog::Goal] the given Goal for the Rule.
    # @param subgoal [Porolog::Goal] the subgoal for the Rule's definition.
    # @param block [Proc] code to perform when the definition is satisfied.
    # @return [Boolean] whether the definition was satisfied.
    def satisfy_definition(goal, subgoal, &block)
      case @definition
        when TrueClass
          block.call(subgoal)
          true
        
        when FalseClass
          false
        
        when Array
          satisfy_conjunction(goal, subgoal, @definition) do |solution_goal|
            block.call(solution_goal)
          end
        
        else
          raise DefinitionError, "UNEXPECTED TYPE OF DEFINITION: #{@definition.inspect} (#{@definition.class})"
      end
    end
    
    # Try to satisfy the conjunction of the definition of the Rule for a given Goal.
    # A conjunction is a sequence of expressions where the sequence is true
    # if all the expressions are true.
    #
    # @param goal [Porolog::Goal] the given Goal for the Rule.
    # @param subgoal [Porolog::Goal] the subgoal for the Rule's definition.
    # @param conjunction [Array] the conjunction to satisfy.
    # @param block [Proc] code to perform when the definition is satisfied.
    # @return [Boolean] whether the definition was satisfied.
    def satisfy_conjunction(goal, subgoal, conjunction, &block)
      arguments   = conjunction.first
      conjunction = conjunction[1..-1]
      
      # -- Handle non-Arguments --
      case arguments
        when :CUT, true
          subgoal.log << "CUTTING #{goal.inspect}..."
          result = true
          if conjunction.empty?
            block.call(subgoal)
          else
            result = satisfy_conjunction(goal, subgoal, conjunction, &block)
          end
          
          if arguments == :CUT
            goal.terminate!
            goal.log << "TERMINATED after #{subgoal.inspect}"
          end
          
          return result
          
        when false
          return false
        
        when nil
          block.call(subgoal)
          return true
      end
      
      # -- Unify Subsubgoal --
      subsubgoal = arguments.goal(subgoal)
      unified    = subsubgoal.inherit_variables(subgoal)
      
      # -- Satisfy Subgoal --
      result = false
      unified && subsubgoal.satisfy() do
        result = true
        if conjunction.empty?
          block.call(goal)
        else
          result = satisfy_conjunction(goal, subsubgoal, conjunction, &block)
        end
      end
      
      # -- Uninstantiate --
      subsubgoal.delete!
      
      result
    end
    
  end
  
end
