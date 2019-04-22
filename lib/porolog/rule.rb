#
#   lib/porolog/rule.rb      - Plain Old Ruby Objects Prolog Engine -- Rule
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Rule is one clause of a Porolog::Predicate.
  # @author Luis Esteban
  # @!attribute [r] arguments
  #   The Arguments of the Predicate for which this Rule applies.
  # @!attribute [r] definition
  #   The definition of the Rule.
  class Rule
    
    attr_reader :arguments, :definition
    
    # Clears all Rules.
    # @return [true]
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
    
    # @return [String] pretty representation
    def inspect
      "  #{@arguments.inspect}:- #{@definition.inspect}"
    end
    
  end
  
end
