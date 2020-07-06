#
#   lib/porolog/arguments.rb      - Plain Old Ruby Objects Prolog Engine -- Arguments
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Arguments specifies arguments of a Predicate.
  # A predicate is not like a subroutine, although there are many similarities.
  # An Arguments represents an instance of a predicate with a specific set of arguments.
  # This forms the basis for implementing a goal to solve the predicate with those specific arguments.
  #
  # @author Luis Esteban
  #
  # @!attribute [r] predicate
  #   The Predicate for which these are the arguments.
  # @!attribute [r] arguments
  #   The actual arguments.
  class Arguments
    
    attr_reader :predicate, :arguments
    
    # Unregisters all Arguments
    # @return [true]
    def self.reset
      @@arguments = []
      true
    end
    
    reset
    
    # Creates a new Arguments for a Predicate
    # @param predicate [Porolog::Predicate] the Predicate for which these are the arguments
    # @param arguments [Array<Object>] the actual arguments
    def initialize(predicate, arguments)
      @predicate = predicate
      @arguments = arguments
      @@arguments << self
    end
    
    # Convenience method for testing/debugging
    # @return [Array<Porolog::Arguments>] all registered Arguments
    def self.arguments
      @@arguments
    end
    
    # Convenience method for testing/debugging
    # @return [String] pretty identification
    def myid
      "Arguments#{(@@arguments.index(self) || -1000) + 1}"
    end
    
    # @return [String] pretty representation
    def inspect
      "#{@predicate && @predicate.name}(#{@arguments && @arguments.map(&:inspect).join(',')})"
    end
    
    # Creates a fact rule that states that these arguments satisfy the Predicate.
    # @return [Porolog::Arguments] the Arguments
    def fact!
      @predicate << Rule.new(self, true)
      self
    end
    
    # Creates a fact rule that states that these arguments do not satisfy the Predicate.
    # @return [Porolog::Arguments] the Arguments
    def falicy!
      @predicate << Rule.new(self, false)
      self
    end
    
    # Creates a fact rule that states that these arguments satisfy the Predicate and terminates solving the predicate.
    # @return [Porolog::Arguments] the Arguments
    def cut_fact!
      @predicate << Rule.new(self, [:CUT, true])
      self
    end
    
    # Creates a fact rule that states that these arguments do not satisfy the Predicate and terminates solving the predicate.
    # @return [Porolog::Arguments] the Arguments
    def cut_falicy!
      @predicate << Rule.new(self, [:CUT, false])
      self
    end
    
    # Adds a Rule to the Predicate for these Arguments
    # @param definition [Array<Object>, Object] the Rule definition for these Arguments
    # @return [Porolog::Arguments] the Arguments
    def <<(*definition)
      @predicate << Rule.new(self, *definition)
      self
    end
    
    # Adds an evaluation Rule to the Predicate
    # @param block the block to evaluate
    # @return [Porolog::Arguments] the Arguments
    def evaluates(&block)
      @predicate << Rule.new(self, block)
      self
    end
    
    # @return [Array<Symbol>] the variables contained in the arguments
    def variables
      @arguments.map{|argument|
        argument.variables
      }.flatten.uniq
    end
    
    # Creates a Goal for solving this Arguments for the Predicate
    # @param calling_goal [Porolog::Goal] the parent Goal (if this is a subgoal)
    # @return [Porolog::Goal] the Goal to solve
    def goal(calling_goal = nil)
      Goal.new(self, calling_goal)
    end
    
    # Returns memoized solutions
    # @param max_solutions [Integer] the maximum number of solutions to find (nil means find all)
    # @return [Array<Hash{Symbol => Object}>] the solutions found (memoized)
    def solutions(max_solutions = nil)
      @solutions ||= solve(max_solutions)
      @solutions
    end
    
    # Solves the Arguments
    # @param max_solutions [Integer] the maximum number of solutions to find (nil means find all)
    # @return [Array<Hash{Symbol => Object}>] the solutions found
    def solve(max_solutions = nil)
      @solutions = goal.solve(max_solutions)
    end
    
    # Extracts solution values.
    # @param variables [Symbol, Array<Symbol>] variable or variables
    # @return [Array<Object>] all the values for the variables given
    # @example
    #   predicate :treasure_at
    #   treasure_at(:X,:Y) << [...]
    #   arguments = treasure_at(:X,:Y)
    #   xs = arguments.solve_for(:X)
    #   ys = arguments.solve_for(:Y)
    #   coords = xs.zip(ys)
    def solve_for(*variables)
      variables = [*variables]
      solutions.map{|solution|
        values = variables.map{|variable| solution[variable] }
        if values.size == 1
          values.first
        else
          values
        end
      }
    end
    
    # @return [Boolean] whether any solutions were found
    def valid?
      !solutions.empty?
    end
    
    # Duplicates the Arguments in the context of the given goal
    # @param goal [Porolog::Goal] the destination goal
    # @return [Porolog::Arguments] the duplicated Arguments
    def dup(goal)
      self.class.new @predicate, goal.variablise(arguments)
    end
    
    # @param other [Porolog::Arguments] arguments for comparison
    # @return [Boolean] whether the Arguments match
    def ==(other)
      @predicate == other.predicate &&
      @arguments == other.arguments
    end
    
  end
  
end
