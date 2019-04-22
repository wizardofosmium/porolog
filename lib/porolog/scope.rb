#
#   lib/porolog/scope.rb      - Plain Old Ruby Objects Prolog Engine -- Scope
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog

  # A Porolog::Scope is a container for Porolog::Predicates.
  # Its purpose is to allow a Ruby program to contain multiple Prolog programs
  # without the Prolog programs interfering with each other.
  # @author Luis Esteban
  # @!attribute [r] name
  #   Name of the Scope.
  class Scope
    
    # Error class for rescuing or detecting any Scope error.
    class ScopeError        < PorologError ; end
    # Error class indicating a non-Predicate was assigned to a Scope.
    class NotPredicateError < ScopeError   ; end
    
    attr_reader :name
    
    # Creates a new Scope unless it already exists.
    # @param name [Symbol, Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Scope] new or existing Scope.
    def self.new(name)
      @@scopes[name] || super
    end
    
    # Initializes and registers the Scope.
    # @param name [Object] the name (or otherwise object) used to register a scope.
    def initialize(name)
      @name       = name
      @predicates = {}
      
      @@scopes[@name] = self
    end
    
    # Clears all scopes and re-creates the default Scope.
    # @return [Porolog::Scope] the default Scope.
    def self.reset
      @@scopes = {}
      new(:default)
    end
    
    reset
    
    # Looks up a Scope by its name.
    # @param name [Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Scope] the default Scope.
    def self.[](name)
      @@scopes[name]
    end
    
    # Returns the names of all registered Scopes.
    # @return [Array<Symbol>] the names if scopes are named as Symbols (the intended case).
    # @return [Array<Object>] the names if the names are not actually Symbols.
    def self.scopes
      @@scopes.keys
    end
    
    # Looks up a Predicate in the Scope by its name.
    # @param name [Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Predicate] the Predicate indicated by the name.
    def [](name)
      @predicates[name.to_sym]
    end
    
    # Assigns a Predicate to the Scope by its name.
    # @param name [Object] the name (or otherwise object) used to register a scope.
    # @param predicate [Porolog::Predicate] a Predicate to be assigned to the Scope.
    # @return [Porolog::Predicate] the Predicate assigned to the Scope.
    # @raise [NotPredicateError] when provided predicate is not actually a Predicate.
    def []=(name,predicate)
      raise NotPredicateError.new("#{predicate.inspect} is not a Predicate") unless predicate.is_a?(Predicate)
      @predicates[name.to_sym] = predicate
    end
    
    # Returns the Predicates contained in the Scope.
    # @return [Array<Porolog::Predicate>] Predicates assigned to the Scope.
    def predicates
      @predicates.values
    end
    
  end

end
