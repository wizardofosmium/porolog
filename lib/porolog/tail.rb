#
#   lib/porolog/tail.rb      - Plain Old Ruby Objects Prolog Engine -- Tail
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Tail is used to represent the tail of a list.
  #
  # It corresponds to the use of the splat operator within an Array.
  #
  # @author Luis Esteban
  #
  # @!attribute value
  #   @return [Object] The value of the tail.
  class Tail
    
    # Creates a new Tail for an Array.
    # @param value [Object] the value of the tail.
    def initialize(value = UNKNOWN_TAIL)
      @value = value
    end
    
    # Returns the value of the Tail.
    # The optional arguments are ignored; this is for polymorphic compatibility with Porolog::Value and Porolog::Variable,
    # which are used to prevent inifinite recursion.
    # @return [Object] the value of the Tail.
    def value(*)
      @value
    end
    
    # @return [String] pretty representation.
    def inspect
      "*#{@value.inspect}"
    end
    
    # @return [Array] embedded variables.
    def variables
      @value.variables
    end
    
    # @param other [Object, #value]
    # @return [Boolean] whether the value of the Tail is equal to the value of another Object.
    def ==(other)
      @value == other.value
    end
    
  end
  
end
