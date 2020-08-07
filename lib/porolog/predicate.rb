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
    
    # A unique value used to verify instantiations.
    UNIQUE_VALUE = Object.new.freeze
    private_constant :UNIQUE_VALUE
    
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
    def initialize(name, scope_name = Predicate.scope.name, builtin: false)
      @name    = name.to_sym
      @rules   = []
      @builtin = builtin
      
      raise NameError, "Cannot name a predicate 'predicate'" if @name == :predicate
      
      scope = Scope[scope_name] || Scope.new(scope_name)
      scope[@name] = self
    end
    
    # Creates a new Predicate, or returns an existing Predicate if one already exists with the given name in the current scope.
    # @param args the args to be passed to initialize, first of which is the name of the predicate.
    # @return [Porolog::Predicate] a new or existing Predicate.
    def self.new(*args, **)
      scope[args.first.to_sym] || super
    end
    
    # Create Arguments for the Predicate.
    # Provides the syntax option:
    #     p.(x,y,z)
    # for
    #     p.arguments(x,y,z)
    # @return [Porolog::Arguments] Arguments of the Predicate with the given arguments.
    def call(*args, &block)
      Arguments.new(self, args, &block)
    end
    
    # Create Arguments for the Predicate.
    # @param args the args of the Predicate.
    # @param block [Proc,nil] the block to be called when satisfying the Predicate.
    # @return [Porolog::Arguments] Arguments of the Predicate with the given arguments.
    def arguments(*args, &block)
      Arguments.new(self, args, &block)
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
    
    # Satisfy the Predicate within the supplied Goal.
    # Satisfy of each rule of the Predicate is called with the Goal and success block.
    # @param goal [Porolog::Goal] the Goal within which to satisfy the Predicate.
    # @param block [Proc] the block to be called each time a Rule of the Predicate is satisfied.
    # @return [Boolean] whether any Rule was satisfied.
    def satisfy(goal, &block)
      if builtin?
        satisfy_builtin(goal, &block)
      else
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
    
    # @return [Boolean] whether the Predicate is a builtin predicate.
    def builtin?
      @builtin
    end
    
    # Satisfy the builtin Predicate within the supplied Goal.
    # Call the builtin Predicate method with the Goal and success block.
    # The arguments and block are extracted from the Goal's Arguments.
    # @param goal [Porolog::Goal] the Goal within which to satisfy the Predicate.
    # @param block [Proc] the block to be called each time a Rule of the Predicate is satisfied.
    # @return [Boolean] whether any Rule was satisfied.
    def satisfy_builtin(goal, &block)
      predicate = goal.arguments.predicate.name
      arguments = goal.arguments.arguments
      arg_block = goal.arguments.block
      
      Predicate.call_builtin(predicate, goal, block, *arguments, &arg_block)
    end
    
    # Call a builtin predicate
    # @param predicate [Symbol] the name of the predicate to call.
    # @param args [Array<Object>] arguments for the predicate call.
    # @param arg_block [Proc] the block provided in the Arguments of the Predicate.
    # @return [Boolean] whether the predicate was satisfied.
    def self.call_builtin(predicate, *args, &arg_block)
      Porolog::Predicate::Builtin.instance_method(predicate).bind(self).call(*args, &arg_block)
    end
    
  end

end
