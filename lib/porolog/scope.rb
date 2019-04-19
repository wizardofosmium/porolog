#
#   lib/porolog/scope.rb      - Plain Old Ruby Objects Prolog Engine -- Scope
#
#     Luis Esteban   2 May 2018
#       created
#

# == Porolog::Scope ==
#
#   A Porolog::Scope is a container for Porolog::Predicates.
#   Its purpose is to allow a Ruby program to contain multiple Prolog programs
#   without the Prolog programs interfering with each other.
#

module Porolog

  class Scope
    
    class ScopeError        < PorologError ; end
    class NotPredicateError < ScopeError   ; end
    
    attr_reader :name
    
    @@scopes = {}
    
    def self.new(name)
      @@scopes[name] || super
    end
    
    def initialize(name)
      @name       = name
      @predicates = {}
      
      @@scopes[@name] = self
    end
    
    def self.reset
      @@scopes = {}
      new(:default)
    end
    
    reset
    
    def self.[](name)
      @@scopes[name]
    end
    
    def self.scopes
      @@scopes.keys
    end
    
    def [](name)
      @predicates[name.to_sym]
    end
    
    def []=(name,predicate)
      # TODO: Uncomment when Porolog::Predicate has been added.
      #raise NotPredicateError.new("#{predicate.inspect} is not a Predicate") unless predicate.is_a?(Predicate)
      @predicates[name.to_sym] = predicate
    end
    
    def predicates
      @predicates.values
    end
    
  end

end
