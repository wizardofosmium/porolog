#
#   lib/porolog/value.rb      - Plain Old Ruby Objects Prolog Engine -- Value
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Value combines a value with a goal so that when the goal
  # is closed, the value can be uninstantiated at the same time.
  #
  # @author Luis Esteban
  #
  # @!attribute goal
  #   @return [Porolog::Goal] The goal in which the value was instantiated.
  # @!attribute instantiations
  #   @return [Array<Porolog::Instantiation>] Instantiations of this value.
  #
  class Value
    
    # Error class for rescuing or detecting any Value error.
    class Error     < PorologError ; end
    # Error class indicating that the supplied goal is not actually a goal.
    class GoalError < Error        ; end
    
    attr_accessor :goal, :instantiations
    
    # @param value [Object] the value to be associated with a Goal.
    # @param goal [Porolog::Goal] the Goal to be associated.
    # @return [Porolog::Value] the Value.
    def initialize(value, goal)
      raise GoalError, "Not a Goal: #{goal.inspect}" unless goal.is_a?(Goal)
      
      @value = value
      @value = value.value if value.is_a?(Value)
      @goal  = goal
      
      @instantiations = []
    end
    
    # Pretty presentation.
    # @return [String] the inspect of the value prefixed by the goal id.
    def inspect
      "#{@goal.myid}.#{@value.inspect}"
    end
    
    # Pretty presentation with instantiations and indexes.
    # This method is for polymorphic compatibility with Porolog::Variable.
    # It used by Porolog::Goal#inspect_variables.
    # @param visited [Array] the values already visited (to prevent infinite recursion).
    # @param depth [Integer] the level of indentation that shows containment.
    # @param index [Integer,Symbol,Array] the index into this value.
    # @param self_index [Integer,Symbol,Array] the index of which this value belongs.
    # @return [String] the inspect of the value in the context of the variables of a goal.
    def inspect_with_instantiations(visited = [], depth = 0, index = nil, self_index = nil)
      index_str = index      && "[#{index.inspect}]"    || ''
      prefix    = self_index && "#{self_index.inspect}" || ''
      
      "#{'  ' * depth}#{prefix}#{inspect}#{index_str}"
    end
    
    # Uninstantiate the Value.
    # @return [Boolean] true
    def remove
      @instantiations.dup.each(&:remove)
      @instantiations[0..-1] = []
      true
    end
    
    # Passes on methods to the Value's value.
    def method_missing(method, *args, &block)
      @value.send(method, *args, &block)
    end
    
    # Responds to all the Value's value methods as well as its own.
    # @return [Boolean] whether the value responds to the method.
    def respond_to?(method, include_all=false)
      @value.respond_to?(method, include_all) || super
    end
    
    # @return [Object] the value of the Value.
    def value(*)
      @value
    end
    
    # @return [Symbol] the type of the value.
    def type
      @value.type
    end
    
    # Compares Values for equality.
    # @return [Boolean] whether the Values' values are equal.
    def ==(other)
      @value == other.value
    end
    
    # @return [Array<Porolog::Variable,Symbol>] variables embedded in the value.
    def variables
      @value.variables
    end
    
  end
  
end
