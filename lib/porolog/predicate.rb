#
#   lib/porolog/predicate.rb      - Plain Old Ruby Objects Prolog Engine -- Predicate
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Predicate corresponds to a Prolog predicate.
  # It contains rules (Porolog::Rule) and belongs to a Porolog::Scope.
  # When provided with arguments, it produces a Porolog::Arguments.
  # @author Luis Esteban
  # @!attribute [r] name
  #   Name of the Predicate.
  # @!attribute [r] rules
  #   Rules of the Predicate.
  class Predicate
    
    # Error class for rescuing or detecting any Predicate error.
    class PredicateError < PorologError   ; end
    # Error class indicating an error with the name of a Predicate.
    class NameError      < PredicateError ; end
    
    attr_reader :name, :rules
    
    # Returns the current scope, or sets the current scope if a paramter is provided
    # (creating the new scope if necessary).
    # @param scope_name [Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Scope] the current Scope.
    def self.scope(scope_name = nil)
      if scope_name
        @@current_scope = Scope[scope_name] || Scope.new(scope_name)
      else
        @@current_scope
      end
    end
    
    # Sets the current scope (creating the new scope if necessary.
    # @param scope_name [Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Scope] the current Scope.
    def self.scope=(scope_name)
      if scope_name
        @@current_scope = Scope[scope_name] || Scope.new(scope_name)
      end
      @@current_scope
    end
    
    # Resets the current scope to default and deregisters builtin predicates.
    # @return [Porolog::Scope] the current Scope.
    def self.reset
      scope(:default)
      @builtin_predicate_ids = {}
    end
    
    # Looks up a Predicate in the current scope by its name.
    # @param name [Object] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Predicate] the Predicate with the given name.
    def self.[](name)
      @@current_scope[name]
    end
    
    reset
    
    # Initializes a Porolog::Predicate and registers it by its name.
    # @param name [#to_sym] the input object to read from
    # @param scope_name the name of the scope in which to register the Predicate; if omitted, defaults to the name of the current scope
    def initialize(name, scope_name = Predicate.scope.name)
      @name  = name.to_sym
      @rules = []
      
      raise NameError.new("Cannot name a predicate 'predicate'") if @name == :predicate
      
      scope = Scope[scope_name] || Scope.new(scope_name)
      scope[@name] = self
    end
    
    # Creates a new Predicate, or returns an existing Predicate if one already exists with the given name in the current scope.
    # @return [Porolog::Predicate] a new or existing Predicate.
    def self.new(*args)
      name, _ = *args
      scope[name.to_sym] || super
    end
    
    # Create Arguments for the Predicate.
    # Provides the syntax options:
    # * p.(x,y,z)
    # @return [Porolog::Arguments] Arguments of the Predicate with the given arguments.
    def call(*args)
      Arguments.new(self,args)
    end
    
    # Create Arguments for the Predicate.
    def arguments(*args)
      Arguments.new(self,args)
    end
    
    # Add a Rule to the Predicate.
    # @param rule [Object] the name (or otherwise object) used to register a scope.
    # @return [Array<Porolog::Rule>] the Predicate's rule.
    def <<(rule)
      @rules << rule
    end
    
    # A pretty print String of the Predicate.
    # @return [String] the Predicate as a String.
    def inspect
      lines = []
      
      if @rules.size == 1
        lines << "#{@name}:-#{@rules.first.inspect}"
      else
        lines << "#{@name}:-"
        @rules.each do |rule|
          lines << rule.inspect
        end
      end
        
      lines.join("\n")
    end
    
    # Return a builtin Predicate based on its key.
    # @param key [Symbol] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Predicate] a Predicate with the next id based on the key.
    def self.builtin(key)
      @builtin_predicate_ids[key] ||= 0
      @builtin_predicate_ids[key]  += 1
      
      self.new("_#{key}_#{@builtin_predicate_ids[key]}")
    end
    
  end

end
