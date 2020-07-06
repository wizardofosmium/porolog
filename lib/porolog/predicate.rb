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
  #
  # @author Luis Esteban
  #
  # @!attribute [r] name
  #   Name of the Predicate.
  #
  # @!attribute [r] rules
  #   Rules of the Predicate.
  #
  class Predicate
    
    # Error class for rescuing or detecting any Predicate error.
    class Error          < PorologError   ; end
    # Error class indicating an error with the name of a Predicate.
    class NameError      < Error          ; end
    
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
      @@current_scope = Scope[scope_name] || Scope.new(scope_name)  if scope_name
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
      
      raise NameError, "Cannot name a predicate 'predicate'" if @name == :predicate
      
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
    # Provides the syntax option:
    #     p.(x,y,z)
    # for
    #     p.arguments(x,y,z)
    # @return [Porolog::Arguments] Arguments of the Predicate with the given arguments.
    def call(*args)
      Arguments.new(self,args)
    end
    
    # Create Arguments for the Predicate.
    # @return [Porolog::Arguments] Arguments of the Predicate with the given arguments.
    def arguments(*args)
      Arguments.new(self,args)
    end
    
    # Add a Rule to the Predicate.
    # @param rule [Object] a rule to add to the Predicate.
    # @return [Porolog::Predicate] the Predicate.
    def <<(rule)
      @rules << rule
      self
    end
    
    # A pretty print String of the Predicate.
    # @return [String] the Predicate as a String.
    def inspect
      if @rules.size == 1
        "#{@name}:-#{@rules.first.inspect}"
      else
        @rules.each_with_object(["#{@name}:-"]) do |rule, lines|
          lines << rule.inspect
        end.join("\n")
      end
    end
    
    # Return a builtin Predicate based on its key.
    # @param key [Symbol] the name (or otherwise object) used to register a scope.
    # @return [Porolog::Predicate] a Predicate with the next id based on the key.
    def self.builtin(key)
      @builtin_predicate_ids[key] ||= 0
      @builtin_predicate_ids[key]  += 1
      
      self.new("_#{key}_#{@builtin_predicate_ids[key]}")
    end
    
    # Satisfy the Predicate within the supplied Goal.
    # Satisfy of each rule of the Predicate is called with the Goal and success block.
    # @param goal [Porolog::Goal] the Goal within which to satisfy the Predicate.
    # @param block [Proc] the block to be called each time a Rule of the Predicate is satisfied.
    # @return [Boolean] whether any Rule was satisfied.
    def satisfy(goal, &block)
      satisfied = false
      @rules.each do |rule|
        rule.satisfy(goal) do |subgoal|
          satisfied = true
          block.call(subgoal)
        end
        break if goal.terminated?
      end
      satisfied
    end
    
  end

end
